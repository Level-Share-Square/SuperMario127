extends EditorTool

const REGULAR_MODULATE := Color(1, 1, 1, 0.5)
const ERASE_MODULATE := Color(1, 0.2, 0.2, 0.5)

onready var object_buffer = $"%ObjectBuffer"

var last_mouse_tile: Vector2
var mouse_input: int = -1
var objects: Dictionary = {}
var is_erasing: bool = false
onready var item_preview = $"%ItemPreview"


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	is_erasing = tool_manager.is_erasing
	click()


func _click_left_released(_event: InputEvent, _world_pos: Vector2) -> void:
	is_erasing = tool_manager.is_erasing
	click_released()


func _click_right(event: InputEvent, world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	is_erasing = not tool_manager.is_erasing
	click()


func _click_right_released(event: InputEvent, world_pos: Vector2) -> void:
	is_erasing = not tool_manager.is_erasing
	click_released()


func _mouse_movement(event: InputEvent, world_pos: Vector2) -> void:
	if editor.selected_item is PlaceableObject:
		var mouse_tile: Vector2 = get_mouse_snapped_pos()
		var line: = line_util.get_line(last_mouse_tile, mouse_tile)
	
		item_preview.position_override = true
		item_preview.rect_global_position = (get_node("%ParallaxScroll").get_transform().xform(get_mouse_snapped_pos() - item_preview.texture.get_size()/2))

		if mouse_input == 0:
			for point in line:
				var point_check = point - Vector2(16, 16)
				if int(point_check.x) % 32 == 0 and int(point_check.y) % 32 == 0:
					draw_object(point)
					
		last_mouse_tile = mouse_tile
		
		if mouse_input == 0 and mouse_tile != last_mouse_tile:
			draw_object(mouse_tile)
			last_mouse_tile = mouse_tile


func click() -> void:
	last_mouse_tile = get_mouse_snapped_pos()
	editor.tile_buffer.modulate = shared.layer_dictionary[editor.layer].layer_tint
	draw_object(last_mouse_tile)
	mouse_input = 0


func click_released() -> void:
	if editor.selected_item is PlaceableObject:
		if mouse_input == 0:
			finalize_placement()
			mouse_input = -1
			last_mouse_tile = get_mouse_snapped_pos()


func draw_object(pos: Vector2) -> void:
	var item = editor.selected_item
	objects.get_or_add(pos, create_object_data(pos, item.object_id, item.palette))
	
	var buffer_texture := TextureRect.new()
	buffer_texture.texture = item.previews[item.palette]
	buffer_texture.rect_global_position = get_mouse_snapped_pos() - item_preview.texture.get_size()/2
	buffer_texture.modulate = REGULAR_MODULATE if not is_erasing else ERASE_MODULATE
	object_buffer.add_child(buffer_texture)

func finalize_placement() -> void:
	if not is_erasing:
		var action := PlaceObjectBulkAction.new()
		action.shared = shared
		action.objects = objects.values().duplicate(true)
		action.layer = editor.layer
		editor.action_manager.commit_action(action)
		for preview in editor.object_buffer.get_children():
			preview.queue_free()
	else:
		var delete_objects: Dictionary
		for pos in objects:
			var object = shared.get_object_at_position(pos, editor.layer)
			if object:
				delete_objects.get_or_add(pos, object)
		var action := EraseObjectBulkAction.new()
		action.shared = shared
		action.objects = delete_objects.values().duplicate(true)
		action.layer = editor.layer
		editor.action_manager.commit_action(action)
		for preview in editor.object_buffer.get_children():
			preview.queue_free()
	objects.clear()

# Mouse coords to tile grid coords
func get_mouse_snapped_pos() -> Vector2:
	return Vector2(int(get_mouse_pos().x / 32) * 32, int(get_mouse_pos().y / 32) * 32) + Vector2(16, 16)

func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var metadata := ObjectMetadata.new(position, object_id, palette)
	var data := ObjectData.new(metadata)
	
	return data
