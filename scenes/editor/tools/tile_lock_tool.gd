extends EditorTool

var mouse_pos
var objects: Array
var positions: Array

func place_object(pos: Vector2):
	if shared.get_object_at_position(Vector2(round(pos.x), round(pos.y)), editor.layer):
		return
	
	var object_item: PlaceableObject = editor.selected_item
	var data = create_object_data(Vector2(round(pos.x), round(pos.y)) if editor.pixel_lock == false else pos.snapped(Vector2(8, 8)), object_item.object_id, object_item.palette)
	
	objects.append(data)
	positions.append(pos)
	var object_preview = TextureRect.new()
	object_preview.texture = editor.selected_item.previews[editor.selected_item.palette]
	object_preview.rect_position = pos - object_preview.texture.get_size()/2
	object_preview.modulate.a = 0.5
	editor.object_buffer.modulate = shared.layer_dictionary[editor.layer].layer_tint
	editor.object_buffer.add_child(object_preview)

func _unhandled_input(event):
	if editor.tool_manager.current_tool == self:
		if editor.hovered_objects.empty():
			if Input.is_action_pressed("place"):
				place_object(mouse_pos)
			if Input.is_action_just_released("place"):
				var action := PlaceObjectBulkAction.new()
				action.shared = shared
				action.objects = objects
				action.layer = editor.layer
				editor.action_manager.commit_action(action)
				for preview in editor.object_buffer.get_children():
					preview.queue_free()
				objects.clear()
				positions.clear()
	mouse_pos = Vector2(int(get_global_mouse_position().x / 32) * 32, int(get_global_mouse_position().y / 32) * 32) + Vector2(16, 16)

func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var metadata := ObjectMetadata.new(position, object_id, palette)
	var data := ObjectData.new(metadata)
	
	return data
