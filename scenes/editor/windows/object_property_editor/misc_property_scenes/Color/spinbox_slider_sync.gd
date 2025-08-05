extends SpinBox


onready var slider: HSlider = get_parent().get_node("HSlider")


func _ready():
	slider.connect("value_changed", self, "_slider_changed")
	connect("value_changed", self, "_spinbox_changed")


func _slider_changed(val):
	value = val


func _spinbox_changed(val):
	slider.value = val
