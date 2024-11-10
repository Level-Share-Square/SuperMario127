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

func _set_properties():
	savable_properties = ["tag", "auto_activate", "move_speed", "offset", "horizontal", "cycle_timer", "cycle_offset"]
	editable_properties = ["tag", "auto_activate", "move_speed", "offset", "horizontal", "cycle_timer", "cycle_offset"]

func _set_property_values():
	set_property("tag", tag)
	set_property("auto_activate", auto_activate, true, "Activate on Start")
	set_property("move_speed", move_speed)
	set_property("offset", offset)
	set_property("horizontal", horizontal)
	set_property("cycle_timer", cycle_timer)
	set_property("cycle_offset", cycle_offset)

func _ready():
	get_parent().connect("objects_ready", self, "ready_synced")
	connect("property_changed", self, "_on_property_changed")
	if enabled:
		var _connect = use_area.connect("body_entered", self, "set_liquid_level")
	yield(get_tree(), "physics_frame")
	if mode != 1:
		offset_line.visible = false

	else:
		offset_line.visible = true
	

func ready_synced():
	if mode != 1:
		if auto_activate:
			set_liquid_level(null)
		
		var timer = get_tree().create_timer(cycle_offset+cycle_timer, false)
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
	for found_liquid in Singleton.CurrentLevelData.level_data.vars.liquids:
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
