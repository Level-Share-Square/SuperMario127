extends EditorTool


var last_mouse_tile: Vector2


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if Input.is_action_just_pressed("place"):
		place_object(_world_pos)


func place_object(pos: Vector2):
	if shared.is_object_at_position(Vector2(round(pos.x), round(pos.y))):
		return
	
	var object_item: PlaceableObject = editor.selected_item
	var data = create_object_data(Vector2(round(pos.x), round(pos.y)) if editor.pixel_lock == false else pos.snapped(Vector2(8, 8)), object_item.object_id, object_item.palette)
	
	var action := PlaceObjectAction.new()
	action.shared = shared
	action.object_data = data
	editor.action_manager.commit_action(action)


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var data = ObjectData.new()
	data.type_id = object_id
	data.palette = palette
	data.properties.append(position)
	data.properties.append(Vector2(1, 1))
	data.properties.append(0)
	data.properties.append(true)
	data.properties.append(true)
	data.properties.append(LevelShared.Layers.Middle)
	
	return data
