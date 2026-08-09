extends PropertyTab


func load_properties(_editor: Editor, _objects: Dictionary):
	editor = _editor
	objects = _objects
	
	var dialogue_property: PropertyEditor = $"%DialogueProperty"
	var dialogue_property_info := PropertyInfo.new(dialogue_property.hint_tooltip)
	dialogue_property.load_property(editor, get_property_value(objects.keys()[0], "dialogue"), [
		"dialogue",
		TYPE_STRING_ARRAY,
		dialogue_property_info
	])
	connect_signals(dialogue_property)
	
	var bubble_text_property: PropertyEditor = $"%BubbleText"
	var bubble_property_info := PropertyInfo.new(bubble_text_property.hint_tooltip)
	bubble_text_property.load_property(editor, get_property_value(objects.keys()[0], "bubble_text"), [
		"bubble_text",
		TYPE_STRING,
		bubble_property_info
	])
	connect_signals(bubble_text_property)
