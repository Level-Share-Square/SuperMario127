extends PropertyTab


func load_properties(_editor: Editor, _objects: Dictionary):
	editor = _editor
	objects = _objects
	
	var text_property: PropertyEditor = $"%BigText"
	var property_info := PropertyInfo.new(text_property.hint_tooltip)
	text_property.load_property(editor, get_property_value(objects.keys()[0], "text"), [
		"text",
		TYPE_STRING,
		property_info
	])
	connect_signals(text_property)
