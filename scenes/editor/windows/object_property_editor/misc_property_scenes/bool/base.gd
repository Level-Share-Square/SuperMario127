extends PropertyEditor


func property_changed(key: String, new_value: bool):
	if key != property[0]: return
	$CheckButton.pressed = new_value
