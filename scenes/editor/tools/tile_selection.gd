extends Selector
class_name TileSelector

func _ready():
	yield(editor, "ready")
	editor.action_manager.connect("undo", self, "on_undo")

func on_mouse_released():
	if !.on_mouse_released():
		return
	if fill_rect.has_point(get_adjusted_mouse_position()):
		return
		
	select_tiles()
	
func select_tiles():
	var tile_fill_rect := Rect2(get_tile_grid_position(fill_rect.position), get_tile_grid_position(fill_rect.size))
	
	for x in range(tile_fill_rect.position.x, tile_fill_rect.position.x + tile_fill_rect.size.x):
		for y in range(tile_fill_rect.position.y, tile_fill_rect.position.y + tile_fill_rect.size.y):
			var tile = shared.get_tile(x, y, editor.layer)
			
			if !shared.is_air(tile):
				editor.selected_tiles[Vector2(x, y)] = tile

func reset_bounds():
	.reset_bounds()
	
	editor.selected_tiles.clear()
	
func on_selection_inside_clicked():
	var active_mouse_position: Vector2 = get_adjusted_mouse_position()
	var initial_mouse_position: Vector2 = active_mouse_position
	
	set_buffer()
	
	for position in editor.selected_tiles:
		shared.set_tile(position.x, position.y, editor.layer, 0, 0, 0)
	editor.tile_buffer.modulate = shared.layers[editor.layer].layer_tint
	
	while true:
		var next_pos = yield(self, "mouse_motion")
		
		if !next_pos:
			break
			
		var delta_mouse_position: Vector2 =  next_pos - active_mouse_position

		selection_box.rect_global_position += delta_mouse_position
		fill_rect.position += delta_mouse_position
		
		set_buffer(get_tile_grid_position(next_pos - initial_mouse_position))
		
		active_mouse_position = next_pos
			
	var final_offset = get_tile_grid_position(get_adjusted_mouse_position() - initial_mouse_position)
	var old_positions: Dictionary = editor.selected_tiles
	var new_positions: Dictionary = {}
	
	for position in editor.selected_tiles:
		new_positions[position + final_offset] = editor.selected_tiles[position]
	
	editor.selected_tiles = {}
	move_action(old_positions, new_positions)
		
func set_buffer(offset := Vector2.ZERO):
	editor.tile_buffer.clear()
	for tile_pos in editor.selected_tiles:
		editor.tile_buffer.set_cellv(tile_pos + offset, tile_util.get_real_tile_set_id(editor.selected_tiles[tile_pos][0], editor.selected_tiles[tile_pos][1], editor.selected_tiles[tile_pos][2]))
		editor.tile_buffer.update_bitmask_area(tile_pos + offset)
		
func move_action(old_tiles, new_tiles):
	var action := MoveTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.old_tiles = old_tiles
	action.new_tiles = new_tiles
	editor.action_manager.commit_action(action)
	editor.tile_buffer.clear()
	select_tiles()
	
func on_undo():
	if editor.tool_manager.current_tool == self:
		reset_bounds()
		hide_visuals()
