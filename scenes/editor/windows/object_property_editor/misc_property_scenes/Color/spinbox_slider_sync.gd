extends SpinBox

enum COMPONENT {RED, GREEN, BLUE, ALPHA}

export(COMPONENT) var component = 1
onready var slider: HSlider = get_parent().get_node("HSlider")


func _ready():
	slider.connect("value_changed", self, "_slider_changed")
	connect("value_changed", self, "_spinbox_changed")


func _slider_changed(val):
	value = val


func _spinbox_changed(val):
	slider.value = val


func _on_Wheel_updated(color: Color):
	match component:
		0:
			value = color.r*255
		1:
			value = color.g*255
		2:
			value = color.b*255
