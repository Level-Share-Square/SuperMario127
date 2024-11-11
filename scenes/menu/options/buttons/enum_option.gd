extends OptionBase

export var default_value: int = 0

export (Array, String) var options
	
func pressed():
	var new_value: int = wrapi(value + 1, 0, options.size())
	change_setting(new_value)

func _update_value():
	$Button.text = options[value]

func _get_default_value() -> int:
	return default_value
