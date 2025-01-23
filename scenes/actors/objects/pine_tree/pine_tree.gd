extends Decoration

onready var sprite = $Sprite

var sway : bool = false
var sway_offset : float = rand_range(-1270, 1270)

func _set_properties():
	savable_properties = ["sway"]
	editable_properties = ["sway"]

func _set_property_values():
	set_property("sway", sway, true)

func _process(delta):
	if sway:
		sprite.material.set_shader_param("STRENGTH", sin((OS.get_ticks_msec()/1000.0) + sway_offset)/40.0)
	else:
		sprite.material.set_shader_param("STRENGTH", 0)
