extends PropertyEditor

func property_changed(key: String, new_value):
	if key != property[0]: return
	$ButtonSound.pressed = bool(new_value)
	$ButtonSound.text = property[1][new_value]


func toggled(button_pressed: bool):
	$ButtonSound.text = property[1][button_pressed]
	change_property(button_pressed)
