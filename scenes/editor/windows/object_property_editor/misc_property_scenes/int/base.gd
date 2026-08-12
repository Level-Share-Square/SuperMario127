extends PropertyEditor

func property_changed(key: String, new_value):
	if key != property[0]: return
	$SpinBox.value = int(new_value)

func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	.load_property(_editor, init_value, _property, property_name)
	var property_info = property[2]
	
	$HSlider.hide()
	$Padding.show()
	if property_info is PropertyInfo:
		
		if not is_inf(property_info.max_value) and not is_inf(property_info.max_value):
			$HSlider.show()
			$Padding.hide()
		
		if property_info.enforce_step:
			$SpinBox.step = property_info.step
		$HSlider.step = property_info.step
		$HSlider.share($SpinBox)
		$SpinBox.min_value = property_info.min_value
		$SpinBox.max_value = property_info.max_value
		$SpinBox.custom_arrow_step = property_info.step
		
	property_changed(property[0], init_value)

func change_property(new_value, save_to_data = true):
	.change_property(int(new_value), save_to_data)

func done_editing(actually_changed: bool = true):
	if not actually_changed: return
	change_property($SpinBox.value)
