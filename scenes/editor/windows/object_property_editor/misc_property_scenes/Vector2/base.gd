extends PropertyEditor

func property_changed(key: String, new_value):
	if key != property[0]: return
	if not new_value is Vector2: return
	$X.value = new_value.x
	$Y.value = new_value.y

func load_property(_editor: Editor, init_value, _property: Array, property_name = null):
	.load_property(_editor, init_value, _property, property_name)
	
	var property_info = property[2]
	if property_info is PropertyInfo:
		$X.min_value = property_info.min_value
		$X.max_value = property_info.max_value
		$X.custom_arrow_step = property_info.step

		$Y.min_value = property_info.min_value
		$Y.max_value = property_info.max_value
		$Y.custom_arrow_step = property_info.step
		
		$X.prefix = property_info.prefix[0]
		$X.suffix = property_info.suffix[0]
		
		$Y.prefix = property_info.prefix[1]
		$Y.suffix = property_info.suffix[1]

func change_property(_new_value = null, save_to_data: bool = true):
	var new_value := Vector2(
		float($X.value),
		float($Y.value)
	)
	.change_property(new_value, save_to_data)
