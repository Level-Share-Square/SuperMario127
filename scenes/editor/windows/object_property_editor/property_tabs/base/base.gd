extends PropertyTab

func load_base_properties(_editor: Editor, _objects: Dictionary):
	editor = _editor
	objects = _objects
	
	var position_property: PropertyEditor = $"%Position"
	var scale_property: PropertyEditor = $"%Scale"
	var rotation_property: PropertyEditor = $"%Rotation"
	var visible_property: PropertyEditor = $"%Visible"
	var enabled_property: PropertyEditor = $"%Enabled"
	var palette_property: PropertyEditor = $"%Palette"
	var layer_property: PropertyEditor = $"%Layer"

	var base_hidden_properties: PoolStringArray = []
	for game_object in _objects.keys():
		for hidden_property in game_object.base_hidden_properties:
			if not base_hidden_properties.has(hidden_property):
				base_hidden_properties.append(hidden_property)
	
	if not "position" in base_hidden_properties:
		position_property.load_property(editor, get_property_value(objects.keys()[0], "position"), [
			"position",
			TYPE_VECTOR2,
			PropertyInfo.new(position_property.hint_tooltip)
		])
		connect_signals(position_property)
	else:
		position_property.hide()

	if not "scale" in base_hidden_properties:
		scale_property.load_property(editor, get_property_value(objects.keys()[0], "scale"), [
			"scale",
			TYPE_VECTOR2,
			PropertyInfo.new(scale_property.hint_tooltip, 0.05)
		])
		connect_signals(scale_property)
	else:
		scale_property.hide()

	if not "rotation_degrees" in base_hidden_properties:
		rotation_property.load_property(editor, get_property_value(objects.keys()[0], "rotation_degrees"), [
			"rotation_degrees",
			TYPE_REAL,
			PropertyInfo.new(rotation_property.hint_tooltip)
		])
		connect_signals(rotation_property)
	else:
		rotation_property.hide()

	if not "visible" in base_hidden_properties:
		visible_property.load_property(editor, get_property_value(objects.keys()[0], "visible"), [
			"visible",
			TYPE_BOOL,
			PropertyInfo.new(visible_property.hint_tooltip)
		])
		connect_signals(visible_property)
	else:
		visible_property.hide()

	if not "enabled" in base_hidden_properties:
		enabled_property.load_property(editor, get_property_value(objects.keys()[0], "enabled"), [
			"enabled",
			TYPE_BOOL,
			PropertyInfo.new(enabled_property.hint_tooltip)
		])
		connect_signals(enabled_property)
	else:
		enabled_property.hide()
	
	var placeable_items: Array = objects.values()
	var palette_count: int = placeable_items[0].get_palette_count()
	for placeable_item in placeable_items:
		if placeable_item.get_palette_count() < palette_count:
			palette_count = placeable_item.get_palette_count()
	
	if palette_count > 0:
		palette_property.load_property(editor, get_property_value(objects.keys()[0], "palette"), [
			"palette",
			TYPE_INT,
			PropertyInfo.new(palette_property.hint_tooltip, 1, 0, palette_count)
		])
		connect_signals(palette_property)
	else:
		palette_property.hide()

func flip_objects(multiplier: Vector2): # Hello everybody my name is
	var action := ChangePropertyBulkAction.new()
	action.affected_objects = setup_flipped_objects(multiplier)
	action.bulk_store_original_properties()
	editor.action_manager.commit_action(action)

func setup_flipped_objects(multiplier: Vector2) -> Dictionary:
	var affected_objects: Dictionary
	for object in objects:
		affected_objects[object] = {
			"changed_properties": {
				"scale": object.scale * multiplier
			},
			"original_properties": {}
		}
	return affected_objects
