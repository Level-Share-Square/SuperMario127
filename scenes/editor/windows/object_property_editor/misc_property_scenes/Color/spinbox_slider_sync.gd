extends SpinBox

enum COMPONENT {RED, GREEN, BLUE, ALPHA}

export(COMPONENT) var component
onready var wheel = $"%Wheel"

signal color_change(color, val)


func _ready():
	wheel.connect("updated", self, "_on_Wheel_updated")
	connect("value_changed", self, "_spinbox_changed")
	


func _on_Wheel_updated(color: Color, save: bool):
	match component:
		0:
			value = color.r*255
		1:
			value = color.g*255
		2:
			value = color.b*255
		3:
			value = color.a*255
