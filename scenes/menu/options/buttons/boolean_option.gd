extends OptionBase

export var default_value: bool = false

const ON_TEXT: String = "On"
const OFF_TEXT: String = "Off"

func pressed():
	change_setting(!value)

func _update_value():
	$Button.text = ON_TEXT if value else OFF_TEXT

func _get_default_value() -> bool:
	return default_value
