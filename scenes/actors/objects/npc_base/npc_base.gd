class_name NPCBase
extends GameObject


onready var dialogue_detector = $DialogueDetector
onready var animation_handler = $KinematicBody2D/AnimationHandler

onready var path = $Path2D
onready var pathfollow = $Path2D/PathFollow2D

onready var physicsbody = $KinematicBody2D
onready var rect = $Path2D/PathFollow2D/ReferenceRect

export (Array, String) var expression_map
export (Array, String) var action_map

var curve := Curve2D.new()
var custom_path := Curve2D.new()
var move_type: bool = true
var walk_speed: float = 0
var physics_enabled: bool = true

var path_reference: bool = false
var tag_link: String
var required_shines: int

var speaking_expression: int = 1
var speaking_action: int = 0
var idle_expression: int = 0
var idle_action: int = 0

var gravity: float = 1
var velocity := Vector2.ZERO
var snap := Vector2(0, 12)
var last_position: float = 0
var working_speed: float = 0

var dialogue_trigger: Node


func _set_properties():
	savable_properties = ["curve", "custom_path", "move_type", "walk_speed", "physics_enabled", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "path_reference", "tag_link", "required_shines"]
	editable_properties = ["idle_expression", "idle_action", "speaking_expression", "speaking_action", "tag_link", "custom_path", "walk_speed", "move_type", "physics_enabled", "required_shines", "path_reference"]


func _set_property_values():
	set_property("curve", curve, true)
	set_property("custom_path", curve, true)
	set_property("move_type", move_type, true)
	set_bool_alias("move_type", "Loop", "Reset")
	set_property("walk_speed", walk_speed, true)
	set_property("physics_enabled", physics_enabled, true)
	
	set_property("idle_expression", idle_expression, true)
	set_property_menu("idle_expression", ["option", expression_map.size(), 0, expression_map])
	set_property("idle_action", idle_action, true)
	set_property_menu("idle_action", ["option", action_map.size(), 0, action_map])
	
	set_property("speaking_expression", speaking_expression, true)
	set_property_menu("speaking_expression", ["option", expression_map.size(), 0, expression_map])
	set_property("speaking_action", speaking_action, true)
	set_property_menu("speaking_action", ["option", action_map.size(), 0, action_map])
	
	set_property("path_reference", path_reference, true)
	set_property("tag_link", tag_link, true)
	set_property("required_shines", required_shines, true)


func get_dialogue_from_tag(tag: String) -> Node:
	if tag == "": return null
	for node in get_tree().get_nodes_in_group("TaggedDialogue"):
		if node.tag == tag: return node
	return null


func set_dialogue(dialogue_trigger: Node):
	dialogue_trigger.get_parent().remove_child(dialogue_trigger)
	physicsbody.add_child(dialogue_trigger)
	
	dialogue_trigger.position -= position
	dialogue_trigger.position *= scale.sign()
	dialogue_trigger.scale = scale.sign()
	
	dialogue_trigger.connect("start_talking", self, "start_talking")
	dialogue_trigger.connect("stop_talking", self, "stop_talking")
	dialogue_trigger.connect("change_emote", self, "change_emote")


func _ready():
	stop_talking()
	animation_handler.is_preview = is_preview
	
	path.global_position = global_position
	if(invalid_curve(curve)):
		curve.add_point(Vector2(-50, -50))
		curve.add_point(Vector2(50, -50))
	if(invalid_curve(path.curve)):
		path.curve = curve
	
	if mode == 1:
		# warning-ignore: unused_variable
		connect("property_changed", self, "property_changed")
	else:
		gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity
		yield(get_tree(), "idle_frame")
		working_speed = walk_speed
		pathfollow.loop = !move_type
		physicsbody.set_collision_mask_bit(0, physics_enabled)
		physicsbody.set_collision_mask_bit(4, physics_enabled)
		rect.visible = path_reference
		
		# have to wait for all the dialogue to load in first
		for i in range(5):
			yield(get_tree(), "idle_frame")
		
		if tag_link != "":
			var dialogue_obj: Node = get_dialogue_from_tag(tag_link)
			if is_instance_valid(dialogue_obj):
				set_dialogue(dialogue_obj.get_parent())
		else:
			var overlapping_areas: Array = dialogue_detector.get_overlapping_areas()
			if overlapping_areas.size() > 0:
				for area in overlapping_areas:
					set_dialogue(area.get_parent().get_parent())
					break
		
		if required_shines > 0:
			var collected_shines: int = Singleton.CurrentLevelData.level_info.collected_shines.values().count(true)
			if collected_shines < required_shines:
				queue_free()


func invalid_curve(check : Curve2D):
	if(!is_instance_valid(check) or check.get_point_count() == 0):
		return true
	else:
		return false


func property_changed(key: String, value):
	match(key):
		"idle_expression":
			idle_expression = clamp(value, 0, expression_map.size() -1)
		"speaking_expression": 
			speaking_expression = clamp(value, 0, expression_map.size() - 1)

		"idle_action": 
			idle_action = clamp(value, 0, action_map.size() - 1)
		"speaking_action": 
			speaking_action = clamp(value, 0, action_map.size() - 1)
	
	stop_talking()


func start_talking():
	animation_handler.play_expression(expression_map[speaking_expression])
	animation_handler.play_action(action_map[speaking_action])

func stop_talking():
	animation_handler.play_expression(expression_map[idle_expression])
	animation_handler.play_action(action_map[idle_action])

func change_emote(expression, action):
	animation_handler.play_expression(expression_map[expression])
	animation_handler.play_action(action_map[action])


func _physics_process(delta):
	if curve != path.curve:
		path.curve = curve
	
	if mode != 1:
		if physics_enabled:
			velocity.y += gravity
			velocity.y += gravity
			if walk_speed != 0:
				velocity.x = (pathfollow.global_position.x - physicsbody.global_position.x) / delta
			
			velocity = physicsbody.move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
			if walk_speed != 0:
				if velocity.x != 0:
					animation_handler.play_action("running")
					animation_handler.scale.x = sign(velocity.x)
				else:
					animation_handler.play_action("standing")
			
			last_position = pathfollow.global_position.x
			
		else:
			physicsbody.global_position = pathfollow.global_position
		
		pathfollow.offset += working_speed
		if move_type and (pathfollow.offset >= path.curve.get_baked_length() or pathfollow.offset <= 0):
			working_speed = -working_speed
