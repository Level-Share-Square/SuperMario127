class_name TileMapManager
extends TileMap


var layer_data: LayerData


func _unhandled_input(event):
	if event.is_action_pressed("LMB"):
		place_tile(get_global_mouse_position() / 32, 1, 0, 0, true)
	elif event.is_action_pressed("RMB"):
		remove_tile(get_global_mouse_position() / 32, true)


func place_tile(coords: Vector2, tileset: int, type: int, palette: int, modify_data: bool = false):
	var raw_id = tile_util.get_real_tile_set_id(tileset, type, palette)
	set_cellv(coords, raw_id)
	update_autotile(coords)
	
	if not modify_data:
		return
	
	layer_data.tile_chunks.set_tile(coords, tileset, type, palette)


func remove_tile(coords: Vector2, modify_data: bool = false):
	set_cellv(coords, INVALID_CELL)
	update_autotile(coords)
	
	if not modify_data:
		return
	
	layer_data.tile_chunks.set_tile(coords, -1, -1, -1)


func update_autotile(coords: Vector2, use_godot_autotile: bool = true):
	if use_godot_autotile:
		update_bitmask_area(coords)
	else:
		# Custom autotile logic goes here
		pass
