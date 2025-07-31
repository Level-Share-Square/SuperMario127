extends PropertyEditor

func property_changed(key: String, new_value):
	if key != property[0]: return
	if not new_value is Vector2: return
	$X.value = new_value.x
	$Y.value = new_value.y

func change_property(_new_value = null):
	var new_value := Vector2(
		float($X.text),
		float($Y.text)
	)
	.change_property(new_value)
