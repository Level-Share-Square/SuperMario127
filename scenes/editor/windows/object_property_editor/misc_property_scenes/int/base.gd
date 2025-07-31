extends PropertyEditor

func property_changed(key: String, new_value):
	if key != property[0]: return
	$SpinBox.value = int(new_value)

func load_property(_editor: Editor, _objects: Dictionary, _property: Array):
	.load_property(_editor, _objects, _property)
	
	var property_info = property[2]
	if property_info is PropertyInfo:
		$SpinBox.min_value = property_info.min_value
		$SpinBox.max_value = property_info.max_value
		$SpinBox.custom_arrow_step = property_info.step

func change_property(new_value):
	.change_property(int(new_value))
