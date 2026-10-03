extends OptionBase

export var default_value: int = 0

export (Array, String) var options
export var modification_signal: String = "value_changed"

var slider: HSlider

signal slider_released(new_value)


func slider_changed(new_val: float):
	value = int(new_val)
	change_setting(value)

func _on_drag_ended(_value_changed: bool = true):
	emit_signal("slider_released", slider.value)

func _ready():
	slider = $Panel/HSlider
	slider.min_value = 0
	slider.max_value = options.size() - 1
	slider.set_value_no_signal(value)
	
	slider.connect("drag_ended", self, "_on_drag_ended")
	
	if has_signal(modification_signal):
		connect(modification_signal, self, "slider_changed")
	else:
		slider.connect(modification_signal, self, "slider_changed")

func renamed():
	label.text = name.capitalize() + " - " + options[value]


func _update_value():
	# onready var doesn't work sadly,
	# since base class ready loads before this class's onready
	$Panel/HSlider.set_value_no_signal(value)
	renamed()

func _get_default_value() -> int:
	return default_value
