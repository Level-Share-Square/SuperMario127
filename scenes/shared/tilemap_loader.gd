extends Node2D

export var back_tilemap: NodePath
export var middle_tilemap: NodePath
export var front_tilemap: NodePath

onready var back_tilemap_node = get_node(back_tilemap)
onready var middle_tilemap_node = get_node(middle_tilemap)
onready var front_tilemap_node = get_node(front_tilemap)

var tileset_cache := []

func _ready():
	var level_tilesets := preload("res://assets/tiles/ids.tres")
	for tileset_id in level_tilesets.ids:
		var tileset : LevelTileset = load("res://assets/tiles/" + tileset_id + "/resource.tres")
		tileset_cache.append(tileset)

func get_position_from_tile_index(index: int, size: Vector2) -> Vector2:
	return Vector2(
		index - (floor(index / size.x) * size.x),
		floor(index / size.x)
	)

func get_tile_index_from_position(position: Vector2, size: Vector2) -> int:
	return int(floor((size.x * position.y) + position.x))
	
func get_tile(tileset_id, tile_id):
	var tileset = tileset_cache[tileset_id]
	if tile_id == 0:
		return tileset.block_tile_id
	elif tile_id == 1:
		return tileset.slab_tile_id
	elif tile_id == 2:
		return tileset.left_slope_tile_id
	else:
		return tileset.right_slope_tile_id

func place_edges(pos, placing_tile, bounds, tilemap_node):
	if pos.x == 0:
		tilemap_node.set_cell(-1, pos.y, placing_tile)
	if pos.y == 0:
		tilemap_node.set_cell(pos.x, -1, placing_tile)
	if pos.x == 0 && pos.y == 0:
		tilemap_node.set_cell(-1, -1, placing_tile)
	if pos.x == 0 && pos.y == bounds.y - 1:
		tilemap_node.set_cell(-1, bounds.y, placing_tile)
		
	if pos.x == bounds.x - 1:
		tilemap_node.set_cell(bounds.x, pos.y, placing_tile)
	if pos.y == bounds.y - 1:
		tilemap_node.set_cell(pos.x, bounds.y, placing_tile)
	if pos.x == bounds.x - 1 && pos.y == bounds.y - 1:
		tilemap_node.set_cell(bounds.x, bounds.y, placing_tile)
	if pos.x == bounds.x - 1 && pos.y == 0:
		tilemap_node.set_cell(bounds.x, -1, placing_tile)


func load_in(level_data : LevelData, level_area : LevelArea):
	
	var settings = level_area.settings
	
	back_tilemap_node.clear()
	for index in range(level_area.background_tiles.size()):
		var tile = level_area.background_tiles[index]
		if tile[0] != 0:
			var position = get_position_from_tile_index(index, level_area.settings.size)
			var cache_tile = get_tile(tile[0], tile[1])
			back_tilemap_node.set_cell(position.x, position.y, get_tile(tile[0], tile[1]))
			place_edges(Vector2(position.x, position.y), cache_tile, level_area.settings.size, back_tilemap_node)
			
	middle_tilemap_node.clear()
	for index in range(level_area.foreground_tiles.size()):
		var tile = level_area.foreground_tiles[index]
		if tile[0] != 0:
			var position = get_position_from_tile_index(index, level_area.settings.size)
			var cache_tile = get_tile(tile[0], tile[1])
			middle_tilemap_node.set_cell(position.x, position.y, get_tile(tile[0], tile[1]))
			place_edges(Vector2(position.x, position.y), cache_tile, level_area.settings.size, middle_tilemap_node)
			
	front_tilemap_node.clear()
	for index in range(level_area.very_foreground_tiles.size()):
		var tile = level_area.very_foreground_tiles[index]
		if tile[0] != 0:
			var position = get_position_from_tile_index(index, level_area.settings.size)
			var cache_tile = get_tile(tile[0], tile[1])
			front_tilemap_node.set_cell(position.x, position.y, get_tile(tile[0], tile[1]))
			place_edges(Vector2(position.x, position.y), cache_tile, level_area.settings.size, front_tilemap_node)
	
	back_tilemap_node.update_bitmask_region(Vector2(0, 0), Vector2(settings.size.x, settings.size.y))
	middle_tilemap_node.update_bitmask_region(Vector2(0, 0), Vector2(settings.size.x, settings.size.y))
	front_tilemap_node.update_bitmask_region(Vector2(0, 0), Vector2(settings.size.x, settings.size.y))
