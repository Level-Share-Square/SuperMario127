class_name TileMapManager
extends TileMap


## Replace all instances of this in functions with layer_data.tile_data and
## remove this once we're done testing.
var debug_tile_data: Dictionary = {
	Vector2(0, 0): hash_tile_data(1, 0, 0),
	Vector2(2, 1): hash_tile_data(2, 0, 1),
	Vector2(1, 2): hash_tile_data(1, 0, 2),
	Vector2(7, 2): hash_tile_data(1, 0, 1),
}

var tileset_cache := []
var tileset_palettes := []

var level_data: LevelDataOld
var area_data: LevelAreaOld
var layer_data: LevelLayerData


static func hash_tile_data(tileset: int, tile: int, palette: int) -> int:
	var t: int = tileset << 48
	var v: int = tile << 32
	var p: int = palette << 16
	return t | v | p


static func fix_hashed_tile_data(value: int) -> PoolIntArray:
	var data: PoolIntArray = [0, 0, 0]
	data[0] = value >> 48 & 0xFFFF
	data[1] = value >> 32 & 0xFFFF
	data[2] = value >> 16 & 0xFFFF
	
	return data


func _ready():
	var level_tilesets := preload("res://assets/tiles/ids.tres")
	
	for tileset_id in level_tilesets.ids:
		var tileset : LevelTileset = load("res://assets/tiles/" + tileset_id + "/resource.tres")
		tileset_cache.append(tileset)
	
	tileset_palettes = preload("res://generation/tileset_palettes.res").tileset_palettes
	
#	load_tiles(debug_tile_data)


func _unhandled_input(event):
	if event.is_action_pressed("LMB"):
		place_tile(TileData.new(1, 0, 0, get_global_mouse_position() / 32), true)
	elif event.is_action_pressed("RMB"):
		remove_tile(get_global_mouse_position() / 32, true)

# tile array
func load_tiles(tiles: Array):
	for tile in tiles:
		place_tile(tile, false)
	
	update_dirty_quadrants()


func place_tile(tile: TileData, modify_data: bool = false):
	var raw_id = get_raw_tile_id(tile.tileset_id, tile.tile_type, tile.palette)
	set_cellv(tile.pos, raw_id)
	update_autotile(tile.pos)
	
	if not modify_data:
		return
	
	if debug_tile_data.has(tile.pos):
		debug_tile_data[tile.pos] = hash_tile_data(tile.tileset_id, tile.tile_type, tile.palette)
	else:
		debug_tile_data.get_or_add(tile.pos, hash_tile_data(tile.tileset_id, tile.tile_type, tile.palette))


func remove_tile(tile_pos: Vector2, modify_data: bool = false):
	set_cellv(tile_pos, INVALID_CELL)
	update_autotile(tile_pos)
	
	if not modify_data:
		return
	
	if debug_tile_data.has(tile_pos):
		debug_tile_data.erase(tile_pos)


func update_autotile(tile_pos: Vector2, use_godot_autotile: bool = true):
	if use_godot_autotile:
		update_bitmask_area(tile_pos)
	else:
		# Custom autotile logic goes here
		pass


func get_tile_at_position(tile_pos: Vector2) -> PoolIntArray:
	return debug_tile_data.get(tile_pos, [0, 0, 0])


func get_raw_tile_id(tileset_id: int, tile_id: int, palette_id: int = 0) -> int:
	if palette_id == 0 or tileset_palettes[tileset_id].size() < palette_id:
		var tileset = tileset_cache[tileset_id]
		if tile_id == 0:
			return tileset.block_tile_id
		elif tile_id == 1:
			return tileset.slab_tile_id
		elif tile_id == 2:
			return tileset.left_slope_tile_id
		else:
			return tileset.right_slope_tile_id
	else:
		var tileset = tileset_palettes[tileset_id]
		return tileset[palette_id - 1][tile_id]
