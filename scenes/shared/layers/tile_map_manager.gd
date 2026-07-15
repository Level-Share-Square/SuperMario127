class_name TileMapManager
extends TileMap


var layer_data: LayerData


#func _unhandled_input(event):
#	if event.is_action_pressed("LMB"):
#		place_tile(get_global_mouse_position() / 32, 1, 0, 0, true)
#	elif event.is_action_pressed("RMB"):
#		erase_tile(get_global_mouse_position() / 32, true)


func load_in(s_layer_data: LayerData):
	layer_data = s_layer_data
	
	clear()
	
	if not layer_data.layer_metadata.is_ground:
		collision_layer = 0
		collision_mask = 0
	
	var packed_tile: int = 0
	var min_tile_coord: Vector2
	var max_tile_coord: Vector2
	for coord in layer_data.tile_data.used_tiles:
		if min_tile_coord.x > coord.x and min_tile_coord.y > coord.y:
			min_tile_coord = coord
		
		if max_tile_coord.x < coord.x and max_tile_coord.y < coord.y:
			max_tile_coord = coord
		
		packed_tile = layer_data.tile_data.get_packed_tile_at(coord)
		place_tile(
			coord,
			tile_util.get_tile_set_id_from_packed(packed_tile),
			tile_util.get_tile_id_from_packed(packed_tile),
			tile_util.get_palette_id_from_packed(packed_tile),
			false
		)
	
	update_bitmask_region(min_tile_coord, max_tile_coord)
	update_dirty_quadrants()


func place_tile(coords: Vector2, tileset: int, type: int, palette: int, update_autotile: bool = true, modify_data: bool = false):
	set_cellv(coords, tile_util.get_real_tile_set_id(tileset, type, palette))
	
	if update_autotile:
		update_autotile(coords)
	
	if not modify_data:
		return
	
	layer_data.tile_data.set_tile(coords, tileset, type, palette)


func erase_tile(coords: Vector2, modify_data: bool = false):
	set_cellv(coords, INVALID_CELL)
	update_autotile(coords)
	
	if not modify_data:
		return
	
	layer_data.tile_data.set_tile(coords, -1, -1, -1)


func update_autotile(coords: Vector2, use_godot_autotile: bool = true):
	if use_godot_autotile:
		update_bitmask_area(coords)
	else:
		# Custom autotile logic goes here
		pass
