extends GameObject

onready var use_area = $UseArea
onready var anim_player = $AnimationPlayer

var tag := "default"
var auto_activate := false
var move_speed := 1.0

func _set_properties():
	savable_properties = ["tag", "auto_activate", "move_speed"]
	editable_properties = ["tag", "auto_activate", "move_speed"]

func _set_property_values():
	set_property("tag", tag)
	set_property("auto_activate", auto_activate)
	set_property("move_speed", move_speed)

func _ready():
	var _connect = use_area.connect("body_entered", self, "set_liquid_level")
	yield(get_tree(), "physics_frame")
	if auto_activate and mode != 1:
		set_liquid_level(null)

func set_liquid_level(body):
	if body != null:
		anim_player.play("touch")
	for found_liquid in CurrentLevelData.level_data.vars.liquids:
		if found_liquid[0] == tag.to_lower():
			found_liquid[1].moving = true
			found_liquid[1].match_level = global_position.y
			found_liquid[1].move_speed = move_speed
