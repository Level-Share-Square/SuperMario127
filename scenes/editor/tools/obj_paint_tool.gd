extends EditorTool


var last_mouse_tile: Vector2

signal objects_selected(objects)

func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	editor.get_hovered_objects()
	
	if editor.selected_objects.empty() && editor.hovered_objects.empty():
		if Input.is_action_just_pressed("place"):
			place_object(_world_pos)
	elif !editor.hovered_objects.empty():
		var closest_object = editor.hovered_objects.values()[0]
		for object in editor.hovered_objects.values():
			if Vector2(abs(object.global_position.x - get_mouse_pos().x), abs(object.global_position.y - get_mouse_pos().y)) < closest_object.global_position:
				closest_object = object
			emit_signal("objects_selected", [closest_object])
	else:
		emit_signal("objects_selected", [])
		pass
		
func place_object(pos: Vector2):
	if shared.get_object_at_position(Vector2(round(pos.x), round(pos.y)), editor.layer):
		return
	
	var object_item: PlaceableObject = editor.selected_item
	var data = create_object_data(Vector2(round(pos.x), round(pos.y)) if editor.pixel_lock == false else pos.snapped(Vector2(8, 8)), object_item.object_id, object_item.palette)
	
	var action := PlaceObjectAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.object_data = data
	editor.action_manager.commit_action(action)


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var metadata := ObjectMetadata.new(position, object_id, palette)
	var data := ObjectData.new(metadata)
	
	return data
