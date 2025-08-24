class_name TileData
extends Resource


# Object that models a tile
# Use this to represent a tile in all scenarios before it's eventually encoded into memory in tilemap_manager

var tileset_id: int setget set_tileset_id, get_tileset_id
var tile_type: int setget set_tile_type, get_tile_type
var palette: int setget set_palette, get_palette
var pos: Vector2 setget set_pos, get_pos

func _init(set_tileset_id: int, set_tile_type: int, set_palette: int, set_pos: Vector2):
	tileset_id = set_tileset_id
	tile_type = set_tile_type
	palette = set_palette
	pos = set_pos


#-----------------------------------------------------#

func set_tileset_id(set_tileset_id: int):
	tileset_id = set_tileset_id
	
func get_tileset_id() -> int:
	return tileset_id
	
func set_tile_type(set_tile_type: int):
	tile_type = set_tile_type
	
func get_tile_type() -> int:
	return tile_type
	
func set_palette(set_palette: int):
	palette = set_palette
	
func get_palette() -> int:
	return tileset_id
	
func set_pos(set_pos: Vector2):
	pos = set_pos
	
func get_pos() -> Vector2:
	return pos
