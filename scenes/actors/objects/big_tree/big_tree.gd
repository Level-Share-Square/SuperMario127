extends Decoration

onready var sprite = $Sprite

var sway : bool = false
var sway_offset : float = rand_range(-127, 127)


func _set_property_values():
	register_property(4, "sway", sway)


func _object_process(delta):
	if sway:
		sprite.material.set_shader_param("strength", sin((OS.get_ticks_msec()/1000.0) + sway_offset)/30.0)
	else:
		sprite.material.set_shader_param("strength", 0)
