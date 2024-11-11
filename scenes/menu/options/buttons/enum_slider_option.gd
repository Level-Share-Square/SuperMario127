extends OptionBase

export var default_value: int = 0

export (Array, String) var options

func slider_changed(new_val: float):
	value = int(new_val)
	change_setting(value)


func _ready():
	var slider = $Panel/HSlider
	slider.min_value = 0
	slider.max_value = options.size() - 1
	slider.set_value_no_signal(value)

func renamed():
	label.text = name.capitalize() + " - " + options[value]


func _update_value():
	# onready var doesn't work sadly,
	# since base class ready loads before this class's onready
	$Panel/HSlider.set_value_no_signal(value)
	renamed()

func _get_default_value() -> int:
	return default_value
