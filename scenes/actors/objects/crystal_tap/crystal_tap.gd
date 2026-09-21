extends GameObject

onready var use_area = $UseArea
onready var anim_player = $AnimationPlayer
onready var offset_line = $Line2D

var auto_activate_time := 0.0

var tag := "default"
var auto_activate := false
var move_speed := 1.0
var offset := 0.0
var horizontal := false
var cycle_timer := 0.0
var cycle_offset := 0.0

#func _set_properties():
#	savable_properties = ["tag", "auto_activate", "move_speed", "offset", "horizontal", "cycle_timer", "cycle_offset"]
#	editable_properties = ["tag", "auto_activate", "move_speed", "offset", "horizontal", "cycle_timer", "cycle_offset"]

func _register_properties():
	register_property(4, "tag", tag)
	set_property_override("tag", PropertyTab.OverrideTypes.DROPDOWN, [CurrentLevelData.level_tags, "get_liquid_args", [CurrentLevelData.level_tags, "liquid_tags"]])
	register_property(5, "auto_activate", auto_activate, true)
	register_property(6, "move_speed", move_speed)
	register_property(7, "offset", offset)
	register_property(8, "horizontal", horizontal)
	register_property(9, "cycle_timer", cycle_timer)
	register_property(10, "cycle_offset", cycle_offset)

func _register_property_info():
	set_property_info("tag", PropertyInfo.new("When this object is touched, liquids with this tag will move to this tap's position.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("auto_activate", PropertyInfo.new("Makes this object activate immediately when loaded.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("move_speed", PropertyInfo.new("The speed at which liquids move when this object is activated.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("offset", PropertyInfo.new("Makes liquids target a position N pixels away from this\nobject, rather than its exact position", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("horizontal", PropertyInfo.new("Makes liquids move to this object's position\nhorizontally, rather than vertically.", 1, -INF, INF, ["", ""], ["", ""], false, ""))
	set_property_info("cycle_timer", PropertyInfo.new("When greater than 0, this object automatically\ntriggers every N seconds.", 1, 0, INF, ["", ""], ["", ""], true, ""))
	set_property_info("cycle_offset", PropertyInfo.new("If not set to 0, the cycle timer will initialize with N seconds left.", 1, 0, INF, ["", ""], ["", ""], true, ""))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and is_object_hovered():
		if event.button_index == 4: # Mouse wheel up
			offset -= 8
			set_property("offset", offset, true)
		elif event.button_index == 5: # Mouse wheel down
			offset += 8
			set_property("offset", offset, true)

func _ready():
	use_area.connect("mouse_entered", self, "_on_UseArea_mouse_entered")
	use_area.connect("mouse_exited", self, "_on_UseArea_mouse_exited")

	connect("property_changed", self, "_on_property_changed")
	yield(get_tree(), "physics_frame")
	if mode != 1:
		offset_line.visible = false

	else:
		offset_line.visible = true

	# This is *supposed* to be called through a signal
	# to ensure all objects are loaded in... but it works
	# without that. Sooooooo i don't care!
	# If it breaks though this is the issue
	# right here VVVV
	ready_synced()
	
func _object_ready():
	if is_enabled_and_on_ground():
		var _connect = use_area.connect("body_entered", self, "set_liquid_level")
	

func ready_synced():
	if mode != 1:
		if auto_activate:
			set_liquid_level(null)
		
		if cycle_timer > 0:
			var timer_length = cycle_timer if cycle_offset == 0.0 else cycle_offset
			var timer = get_tree().create_timer(timer_length, false)
			timer.connect("timeout", self, "autoset_liquid_level")

func _on_property_changed(key, value):
	
	offset_line.global_scale = Vector2(1, 1)
	offset_line.global_rotation = 0
	if(horizontal):
		offset_line.set_point_position(1, Vector2(offset, 0))
	else:
		offset_line.set_point_position(1, Vector2(0, offset))
		
	if "\n" in tag:
		tag = tag.replace("\n", "")

func set_liquid_level(body):
	if body != null and visible:
		anim_player.play("touch")
	for found_liquid in CurrentLevelData.vars.liquids:
		if found_liquid[0] == tag.to_lower():
			found_liquid[1].moving = true
			var match_level = global_position.y
			if horizontal:
				match_level = global_position.x
				found_liquid[1].save_pos = Vector2(global_position.x + offset, found_liquid[1].global_position.y)
			else:
				found_liquid[1].save_pos = Vector2(found_liquid[1].global_position.x, global_position.y + offset)
			found_liquid[1].match_level = match_level + offset
			found_liquid[1].move_speed = move_speed
		
				
			
			#found_liquid[1].save_pos = Vector2(found_liquid[1].global_position.x + (offset if horizontal else 0), global_position.y + (0 if horizontal else offset)) 
			found_liquid[1].horizontal = horizontal

func autoset_liquid_level():
	set_liquid_level(0)
	
	var timer = get_tree().create_timer(cycle_timer, false)
	timer.connect("timeout", self, "autoset_liquid_level")
