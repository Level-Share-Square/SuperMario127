class_name PropertyEditor
extends HBoxContainer

const NAME_TEXT: String = "%s: "

func load_property(property: Array):
	get_node("%PropertyName").text = NAME_TEXT % property[0].capitalize()
	
	var property_info: PropertyInfo = property[2]
	if is_instance_valid(property_info):
		hint_tooltip = property_info.hint
