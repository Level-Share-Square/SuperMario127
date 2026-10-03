func act(editor, position: Vector2, _level_data: LevelDataOld, _level_area: AreaDataOld):
	var shared = editor.get_shared_node()
	var objects = shared.get_objects_node()

	var found_entrance = false

	for object in objects.get_children():
		if object.level_object.get_ref().type_id == 0:
			found_entrance = true
			objects.register_property(object, "position", position)
			break

	return !found_entrance
