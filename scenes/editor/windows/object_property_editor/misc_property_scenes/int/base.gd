extends PropertyEditor

func property_changed(key: String, new_value):
	if key != property[0]: return
	$SpinBox.value = int(new_value)

func change_property(new_value):
	.change_property(int(new_value))
