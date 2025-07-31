extends PropertyEditor

func property_changed(key: String, new_value):
	if key != property[0]: return
	$CheckButton.pressed = bool(new_value)
