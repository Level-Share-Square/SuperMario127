extends EditorTool


var last_mouse_tile: Vector2


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if editor.selected_objects.empty() && editor.hovered_objects.empty():
		if Input.is_action_just_pressed("place"):
			place_object(_world_pos)
	elif !editor.hovered_objects.empty():
		var closest_object = editor.hovered_objects.values()[0]
		for object in editor.hovered_objects.values():
			if Vector2(abs(object.global_position.x - get_global_mouse_position().x), abs(object.global_position.y - get_global_mouse_position().y)) < closest_object.global_position:
				closest_object = object
		if editor.show_layers:
			if closest_object.layer == editor.layer:
				select(closest_object)
			else:
				return
		else:
			select(closest_object)
	else:
		editor.selection_box.get_parent().hide_selection_box()
		for object in editor.selected_objects:
			object.selected = false
		editor.selected_objects = {}
		action()
		editor.selection_box.get_parent().item_actions.hide_selection_actions()
		editor.selection_box.get_parent().pivot_toggle.show()
		editor.selection_box.get_parent().vseparator3.show()
		
#sorry lmao
func select(object: GameObject):
	editor.selected_objects = {}
	editor.selected_objects[object] = object.name
	editor.selection_box.get_parent().show_selection_box()
	editor.selection_box.get_parent().pivot.visible = false
	editor.selection_box.get_parent().pivot_toggle.pressed = false
	action(editor.selected_objects)
	editor.selection_box.get_parent().pivot_toggle.hide()
	editor.selection_box.get_parent().vseparator3.hide()
	
func action(objects: Dictionary = {}) -> void:
	var action := SelectObjectsAction.new()
	action.editor = editor
	action.selection_box = editor.selection_box
	action.selected_objects = objects
	editor.action_manager.commit_action(action)

func place_object(pos: Vector2):
	if shared.is_object_at_position(Vector2(round(pos.x), round(pos.y))):
		return
	
	var object_item: PlaceableObject = editor.selected_item
	var data = create_object_data(Vector2(round(pos.x), round(pos.y)) if editor.pixel_lock == false else pos.snapped(Vector2(8, 8)), object_item.object_id, object_item.palette)
	
	var action := PlaceObjectAction.new()
	action.shared = shared
	action.object_data = data
	editor.action_manager.commit_action(action)


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectDataOld:
	var data = ObjectDataOld.new()
	data.type_id = object_id
	data.palette = palette
	data.properties.append(position)
	data.properties.append(Vector2(1, 1))
	data.properties.append(0)
	data.properties.append(true)
	data.properties.append(true)
#	print(editor.layer)
	data.properties.append(editor.layer if editor.object_layering else LevelShared.Layers.Middle)
	
	return data
