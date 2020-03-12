extends Node2D

export var back_tilemap_path: NodePath
export var middle_tilemap_path: NodePath
export var front_tilemap_path: NodePath

func load_in(level_data : LevelData, level_area : LevelArea):
	var back_tilemap = get_node(back_tilemap_path)
	var middle_tilemap = get_node(middle_tilemap_path)
	var front_tilemap = get_node(front_tilemap_path)
	
	middle_tilemap.clear()
	for index in range(level_area.foreground_tiles.size()):
		var tile = level_area.foreground_tiles[index]
		if tile[0] != 0:
			var position = tile_util.get_position_from_tile_index(index, level_area.settings.size)
			var cache_tile = tile_util.get_tile(tile[0], tile[1])
			middle_tilemap.set_cell(position.x, position.y, tile_util.get_tile(tile[0], tile[1]))
			tile_util.place_edges(Vector2(position.x, position.y), cache_tile, level_area.settings.size, middle_tilemap)
