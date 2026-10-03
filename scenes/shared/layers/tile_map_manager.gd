class_name TileMapManager
extends TileMap


const OOB_TILE: int = 26
var layer_data: LayerData


func load_in(s_layer_data: LayerData):
	layer_data = s_layer_data
	
	clear()
	
	if not layer_data.layer_metadata.is_ground:
		collision_layer = 0
		collision_mask = 0

	var packed_tile: int = 0
	var area_rect: Rect2 = CurrentLevelData.current_area.header.bounds
	var tile_with_edges: bool = CurrentLevelData.current_area.header.tile_with_edges
	for coord in layer_data.tile_data.used_tiles:
		packed_tile = layer_data.tile_data.get_packed_tile_at(coord)
		place_tile(
			coord,
			tile_util.get_tile_set_id_from_packed(packed_tile),
			tile_util.get_tile_id_from_packed(packed_tile),
			tile_util.get_palette_id_from_packed(packed_tile),
			false
		)
#	for chunk in layer_data.tile_data.chunks:
#		create_tilemap_chunk(chunk, layer_data.tile_data.chunks[chunk])

	var border_coords: PoolVector2Array
	if tile_with_edges:
		for x in range(area_rect.position.x - 1, area_rect.position.x + area_rect.size.x):
			border_coords.append(Vector2(x, area_rect.position.y - 1))
			border_coords.append(Vector2(x, area_rect.position.y + area_rect.size.y))
		for y in range(area_rect.position.y - 1, area_rect.position.y + area_rect.size.y):
			border_coords.append(Vector2(area_rect.position.x - 1, y))
			border_coords.append(Vector2(area_rect.position.x + area_rect.size.x, y))
		
		for coord in border_coords:
			if get_cellv(coord) == TileMap.INVALID_CELL:
				set_cellv(coord, OOB_TILE)
	
	update_bitmask_region()
	
	for coord in border_coords:
		if get_cellv(coord) == OOB_TILE:
			set_cellv(coord, TileMap.INVALID_CELL)
	
	update_dirty_quadrants()


func create_tilemap_chunk(chunk_coord: Vector2, chunk_data: PoolIntArray):
	var tilemap_chunk: TileMap = TileMap.new()
	tilemap_chunk.position = chunk_coord * 32 * 16
	tilemap_chunk.cell_size = cell_size
	tilemap_chunk.collision_layer = collision_layer
	tilemap_chunk.collision_mask = collision_mask
	tilemap_chunk.tile_set = tile_set
	
	var visibility_enabler: VisibilityEnabler2D = VisibilityEnabler2D.new()
	visibility_enabler.rect = Rect2(-16, -16, 34 * 16, 34 * 16)
	tilemap_chunk.add_child(visibility_enabler)
	
	var tile_coord: Vector2 = Vector2.ZERO
	for i in range(chunk_data.size()):
		tile_coord = Vector2(i % 16, floor(i / 16))
		tilemap_chunk.set_cellv(tile_coord, tile_util.get_real_tile_set_id_from_packed(chunk_data[i]))
	
	tilemap_chunk.update_bitmask_region()
	tilemap_chunk.update_dirty_quadrants()
	
	add_child(tilemap_chunk)


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
		var area_rect: Rect2 = CurrentLevelData.current_area.header.bounds
		var tile_with_edges: bool = CurrentLevelData.current_area.header.tile_with_edges
		var border_coords: PoolVector2Array
		if tile_with_edges and is_zero_approx(layer_data.layer_metadata.parallax_distance):
			for x in range(coords.x - 3, coords.x + 3):
				for y in range(coords.y - 3, coords.y + 3):
					if not area_rect.has_point(Vector2(x, y)):
						border_coords.append(Vector2(x, y))
			
			for coord in border_coords:
				if get_cellv(coord) == TileMap.INVALID_CELL:
					set_cellv(coord, OOB_TILE)
		
		update_bitmask_area(coords)
		
		for coord in border_coords:
			if get_cellv(coord) == OOB_TILE:
				set_cellv(coord, TileMap.INVALID_CELL)
	else:
		# Custom autotile logic goes here
		pass
