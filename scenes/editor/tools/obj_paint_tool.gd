extends EditorTool


var last_mouse_tile: Vector2
var mouse_input: int = -1


func _click(_event: InputEvent, _world_pos: Vector2) -> void:
	if Input.is_action_just_pressed("place"):
		place_object(_world_pos)
		mouse_input = 0
	
	if Input.is_action_just_pressed("erase"):
		for object in editor.hovered_objects.values():
			erase_object(object)
			break
		


func place_object(pos: Vector2):
	if shared.is_object_at_position(pos):
		return
	
	var object_item: PlaceableObject = editor.selected_item
	var data = create_object_data(pos.snapped(Vector2(8, 8)), object_item.object_id, object_item.palette)
	
	var action := PlaceObjectAction.new()
	action.shared = shared
	action.object_data = data
	editor.action_manager.commit_action(action)
	
	
#	elif Input.is_action_pressed("erase"):
#		for object in editor.hovered_objects.values():
#			editor.hovered_objects.erase(object.name)
#			shared.destroy_object(object, true)
#			break


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


func erase_object(object: GameObject):
	var action := EraseObjectAction.new()
	action.shared = shared
	action.object = object
	editor.hovered_objects.erase(object.name)
	editor.action_manager.commit_action(action)
