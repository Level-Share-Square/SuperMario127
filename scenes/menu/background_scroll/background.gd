extends Control
tool

onready var overlay = $Overlay

export var overlay_tint: Color setget set_color
func set_color(new_value: Color):
	overlay_tint = new_value
	if is_inside_tree():
		overlay.modulate = new_value

export var static_amount: float setget set_static_amount
func set_static_amount(new_value: float):
	static_amount = new_value
	if is_inside_tree():
		overlay.material = overlay.material.duplicate()
		overlay.material.set_shader_param("u_amount", new_value)


func _ready():
	overlay.modulate = overlay_tint
	overlay.material = overlay.material.duplicate()
	overlay.material.set_shader_param("u_amount", static_amount)
