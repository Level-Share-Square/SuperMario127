extends PropertyEditor

var value: bool

func property_changed(key: String, new_value):
	if key != property[0]: return
	$ButtonSound.text = property[1][new_value]
	value = new_value


func pressed():
	value = !value
	$ButtonSound.text = property[1][value]
	change_property(value)
