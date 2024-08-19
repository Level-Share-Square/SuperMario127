extends OptionBase

export var default_value: float = 0

export var min_val: float = 0
export var max_val: float = 100

func slider_changed(new_val: float):
	value = new_val
	change_setting(value)


func _ready():
	var slider = $Panel/HSlider
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = value

func renamed():
	label.text = name.capitalize() + " - " + str(value)


func _update_value():
	# onready var doesn't work sadly,
	# since base class ready loads before this class's onready
	$Panel/HSlider.value = value
	renamed()

func _get_default_value() -> float:
	return default_value
