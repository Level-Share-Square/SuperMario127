class_name TileMapManager
extends TileMap

## Replace all instances of this in functions with layer_data.tile_data and
## remove this once we're done testing.
var debug_tile_data: Dictionary = {
	Vector3(0, 0, 8): Vector3(1, 0, 0),
	Vector3(2, 1, 4): Vector3(2, 0, 1),
	Vector3(1, 2, 6): Vector3(1, 0, 2),
	Vector3(7, 2, 6): Vector3(1, 0, 1),
}

var tileset_cache := []
var tileset_palettes := []

var level_data: LevelData
var area_data: LevelArea
var layer_data: LevelLayerData


func _ready():
	var level_tilesets := preload("res://assets/tiles/ids.tres")
	
	for tileset_id in level_tilesets.ids:
		var tileset : LevelTileset = load("res://assets/tiles/" + tileset_id + "/resource.tres")
		tileset_cache.append(tileset)
	
	tileset_palettes = preload("res://generation/tileset_palettes.res").tileset_palettes
	
	load_tile_strips(debug_tile_data)


func _unhandled_input(event):
	if event.is_action_pressed("LMB"):
		set_tile(get_global_mouse_position() / 32, Vector3(1, 0, 0))
	elif event.is_action_pressed("RMB"):
		set_tile(get_global_mouse_position() / 32, Vector3.ZERO)


func load_tile_strips(data: Dictionary):
	for strip in data:
		var tile_data: Vector3 = data.get(strip)
		for offset in range(strip.z):
			var tile_pos := Vector2(strip.x + offset, strip.y)
			set_tile(tile_pos, tile_data)
	
	update_dirty_quadrants()


func set_tile(tile_pos: Vector2, tile_data: Vector3):
	if tile_data.x == 0:
		_remove_tile(tile_pos)
	else:
		_place_tile(tile_pos, tile_data)


func _place_tile(tile_pos: Vector2, tile_data: Vector3):
	var raw_id = get_raw_tile_id(tile_data.x, tile_data.y, tile_data.z)
	set_cellv(tile_pos, raw_id)
	update_autotile(tile_pos)
	
	for strip in debug_tile_data:
		if strip.y == tile_pos.y:
			var neighbors: Dictionary = get_identical_neighbors(tile_pos, tile_data)
			if neighbors.size() == 2:
				for neighbor in neighbors:
					debug_tile_data.erase(neighbor)
				
				debug_tile_data.merge(
					merge_tile_strip(tile_pos, neighbors),
					true
				)
				return
	
	debug_tile_data.merge({Vector3(tile_pos.x, tile_pos.y, 1): Vector3(1, 0, 0)})


func get_identical_neighbors(tile_pos: Vector2, tile_data: Vector3) -> Dictionary:
	var neighbors: Dictionary = {}
	if get_tile_at_position(Vector2(tile_pos.x - 1, tile_pos.y)) == tile_data:
		var neighbor_left: Dictionary = get_strip_at_position(Vector2(tile_pos.x - 1, tile_pos.y))
		neighbors.merge(neighbor_left)
	
	if get_tile_at_position(Vector2(tile_pos.x + 1, tile_pos.y)) == tile_data:
		var neighbor_right: Dictionary = get_strip_at_position(Vector2(tile_pos.x + 1, tile_pos.y))
		neighbors.merge(neighbor_right)
	
	return neighbors


func _remove_tile(tile_pos: Vector2):
	set_cellv(tile_pos, INVALID_CELL)
	update_autotile(tile_pos)
	
	for strip in debug_tile_data:
		if strip.y == tile_pos.y:
			for offset in range(strip.z):
				var strip_tile_pos := Vector2(strip.x + offset, strip.y)
				if strip_tile_pos.x == tile_pos.x:
					debug_tile_data.merge(
						split_tile_strip(tile_pos, strip),
						true
					)
					return
	
	debug_tile_data.erase(Vector3(tile_pos.x, tile_pos.y, 1))


func merge_tile_strip(tile_pos: Vector2, strips: Dictionary) -> Dictionary:
	if not strips.size() == 2:
		printerr("Cannot merge more than two tile strips!")
		return {}
	
	var leftmost_pos: Vector2
	var merged_length: int = 1
	var tile_data: Vector3
	for strip in strips:
		if leftmost_pos.x > strip.x:
			leftmost_pos = Vector2(strip.x, strip.y)
		
		merged_length += strip.z
	
	var merged_strip: Dictionary = {
		Vector3(leftmost_pos.x, leftmost_pos.y, merged_length): tile_data
	}
	
	return merged_strip


func split_tile_strip(tile_pos: Vector2, strip: Dictionary) -> Dictionary:
	
	
	return {}


func update_autotile(tile_pos: Vector2, use_godot_autotile: bool = true):
	if use_godot_autotile:
		update_bitmask_area(tile_pos)
	else:
		# Custom autotile logic goes here
		pass


func get_strip_at_position(tile_pos: Vector2) -> Dictionary:
	for strip in debug_tile_data:
		if strip.y == tile_pos.y:
			if tile_pos.x >= strip.x and tile_pos.x < strip.x + strip.z:
				return {strip: debug_tile_data.get(strip)}
	
	return {}


func get_tile_at_position(tile_pos: Vector2) -> Vector3:
	for strip in debug_tile_data:
		if strip.y == tile_pos.y:
			if tile_pos.x >= strip.x and tile_pos.x < strip.x + strip.z:
				return debug_tile_data.get(strip)
	
	return Vector3.ZERO


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
