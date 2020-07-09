func act(editor, position: Vector2, _level_data: LevelData, _level_area: LevelArea):
	var shared = editor.get_shared_node()
	var objects = shared.get_objects_node()

	var found_entrance = false

	for object in objects.get_children():
		var level_object = object.level_object.get_ref()
		if object.level_object.get_ref().type_id == 0:
			found_entrance = true
			objects.set_property(object, "position", position)
			break

	return !found_entrance
