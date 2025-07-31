extends PropertyTab

var editor: Editor
var objects: Dictionary

func load_base_properties(_editor: Editor, _objects: Dictionary):
	editor = _editor
	objects = _objects
	
	var position_property: PropertyEditor = $"%Position"
	var scale_property: PropertyEditor = $"%Scale"
	var visible_property: PropertyEditor = $"%Visible"
	var enabled_property: PropertyEditor = $"%Enabled"
	var palette_property: PropertyEditor = $"%Palette"
	
	position_property.load_property(editor, objects, [
		"position",
		typeof(Vector2.ZERO),
		PropertyInfo.new(position_property.hint_tooltip)
	])

	scale_property.load_property(editor, objects, [
		"scale",
		typeof(Vector2.ZERO),
		PropertyInfo.new(scale_property.hint_tooltip, 0.05)
	])

	visible_property.load_property(editor, objects, [
		"visible",
		typeof(true), # True...
		PropertyInfo.new(visible_property.hint_tooltip)
	])

	enabled_property.load_property(editor, objects, [
		"enabled",
		typeof(true),
		PropertyInfo.new(enabled_property.hint_tooltip)
	])
	
	var placeable_items: Array = objects.values()
	var palette_count: int = placeable_items[0].get_palette_count()
	for placeable_item in placeable_items:
		if placeable_item.get_palette_count() < palette_count:
			palette_count = placeable_item.get_palette_count()
	
	if palette_count > 0:
		palette_property.load_property(editor, objects, [
			"palette",
			typeof(0),
			PropertyInfo.new(palette_property.hint_tooltip, 1, 0, palette_count)
		])
	else:
		palette_property.hide()
