extends ButtonPropertyEditor


func load_object_value() -> void:
	var value: bool = get_property_in_object()
	button.pressed = value
