extends GameObject

const rainbow_animation_speed := 1500

export (Array, String) var expression_map
export (Array, String) var action_map

onready var head := $KinematicBody2D/Head
onready var spots := $KinematicBody2D/Head/Spots

onready var body := $KinematicBody2D/Body
onready var coat := $KinematicBody2D/Body/Coat

onready var path = $Path2D
onready var pathfollow = $Path2D/PathFollow2D

onready var physicsbody = $KinematicBody2D

onready var visibility_notifier := $KinematicBody2D/VisibilityNotifier2D

onready var dialogue_object = $Dialogue

onready var rect = $Path2D/PathFollow2D/ReferenceRect

var dialogue := PoolStringArray(["0100Hello! I'm a toad.", "0100Want me to say something different? Click on me in the editor!"])
var character_name: String = "Toad"

var curve = Curve2D.new()
var custom_path = Curve2D.new()
var move_type = true
var walk_speed : float = 0
var physics_enabled = true

var spots_color := Color.red
var coat_color := Color.blue
var rainbow: bool
var path_reference = false

var speaking_expression: int = 1
var speaking_action: int = 0
var idle_expression: int = 0
var idle_action: int = 0
var speaking_radius: float = 90
var interactable: bool = true
var autostart: int = 0

var gravity : float = 1
var velocity : Vector2 = Vector2.ZERO
var snap: = Vector2(0, 12)
var last_position : float = 0
var working_speed : float = 0

func _set_properties():
	savable_properties = ["dialogue", "character_name", "curve", "custom_path", "move_type", "walk_speed", "physics_enabled", "spots_color", "coat_color", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "speaking_radius", "rainbow", "path_reference", "interactable", "autostart"]
	editable_properties = ["dialogue", "character_name", "custom_path", "walk_speed", "move_type", "physics_enabled", "spots_color", "coat_color", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "speaking_radius", "autostart", "interactable", "rainbow", "path_reference"]

func _set_property_values():		
	set_property("dialogue", dialogue, true)
	set_property("character_name", character_name, true)
	
	set_property("curve", curve, true)
	set_property("custom_path", curve, true)
	set_property("move_type", move_type, true)
	set_bool_alias("move_type", "Loop", "Reset")
	set_property("walk_speed", walk_speed, true)
	set_property("physics_enabled", physics_enabled, true)
	
	set_property("spots_color", spots_color, true)
	set_property("coat_color", coat_color, true)
	
	set_property("idle_expression", idle_expression, true)
	set_property_menu("idle_expression", ["option", expression_map.size(), 0, expression_map])
	set_property("idle_action", idle_action, true)
	set_property_menu("idle_action", ["option", action_map.size(), 0, action_map])
	
	set_property("speaking_expression", speaking_expression, true)
	set_property_menu("speaking_expression", ["option", expression_map.size(), 0, expression_map])
	set_property("speaking_action", speaking_action, true)
	set_property_menu("speaking_action", ["option", action_map.size(), 0, action_map])
	set_property("speaking_radius", speaking_radius, true)
	set_property("rainbow", rainbow, true)
	
	set_property("path_reference", path_reference, true)
	
	set_property("interactable", interactable, true)
	set_property("autostart", autostart, true)
	set_property_menu("autostart", ["option", 3, 0, ["Don't Autostart", "Autostart", "Autostart (Oneshot)"]])

func _ready():
	stop_talking()
	
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
	head.play(expression_map[speaking_expression])
	body.play(action_map[speaking_action])

func stop_talking():
	head.play(expression_map[idle_expression])
	body.play(action_map[idle_action])

func message_changed(expression, action):
	head.play(expression_map[expression])
	body.play(action_map[action])


func _physics_process(delta):
	if mode != 1:
		if physics_enabled:
			velocity.y += gravity
			velocity.y += gravity
			if walk_speed != 0:
				velocity.x = (pathfollow.global_position.x - physicsbody.global_position.x) / delta
			
			velocity = physicsbody.move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
			if walk_speed != 0:
				if velocity.x != 0:
					body.play("running")
					if velocity.x < 0:
						body.scale.x = 1
						head.scale.x = 1
					elif velocity.x > 0:
						body.scale.x = -1 
						head.scale.x = -1
				else:
					body.play("standing")
			
			dialogue_object.global_position = physicsbody.global_position
			last_position = pathfollow.global_position.x
			
		else:
			physicsbody.global_position = pathfollow.global_position
			dialogue_object.global_position = physicsbody.global_position
		pathfollow.offset += working_speed
		if move_type and (pathfollow.offset >= path.curve.get_baked_length() or pathfollow.offset <= 0):
			working_speed = -working_speed
			
		

func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		spots_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
		coat_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	spots.modulate = spots_color
	coat.modulate = coat_color
	
	if curve != path.curve:
		path.curve = curve
