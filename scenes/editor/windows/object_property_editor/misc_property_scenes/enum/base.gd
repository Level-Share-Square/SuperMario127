extends PropertyEditor

var values_array: Array
var value: int

func property_changed(key: String, new_value):
	if key != property[0]: return
	value = new_value
	values_array = property[1]
	$ButtonSound.text = values_array[value]


func pressed():
	value = wrapi(value + 1, 0, values_array.size())
	$ButtonSound.text = values_array[value]
	change_property(value)
