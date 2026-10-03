extends PropertyEditor

var text_begin: String

func property_changed(key: String, new_value):
	if key != property[0]: return
	$LineEdit.text = str(new_value)

func change_property(new_value, save_to_data: bool = true):
	.change_property(str(new_value), save_to_data)

func done_editing():
	change_property($LineEdit.text)
