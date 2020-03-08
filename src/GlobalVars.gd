extends Node2D

export var game_mode = "Editing"
export var control_mode = "Normal"
export var gravity = Vector2(0, 7.82)
export var max_gravity_velocity = Vector2(950, 950)
export var levelJSON : Resource
export var areaIndex := 0
export var placement_mode = "Drag"
export var placing_rect := Rect2(96, 0, 32, 32)
export var mouse_hovering := false
export var currently_centered := true
export var saved_code := ""
export var tileset_cache := []
export var id_map_cache := {}
var level := Level.new()
var area : LevelArea
var editor := LevelEditor.new()

var is_tile := true
var selected_object_name : String
var selected_object_id : int
var selected_tile_id := 0
var selected_tileset_id := 1

func _ready():
	level.global_vars_node = self
	
	var level_tilesets : LevelTilesets = load("res://assets/level_tilesets.tres")
	for tileset_id in level_tilesets.tilesets:
		var tileset : LevelTileset = load("res://assets/tilesets/" + tileset_id + ".tres")
		tileset_cache.append(tileset)
		
	var id_mapping : IdMappings = load("res://assets/id_map.tres")
	id_map_cache = id_mapping.mappings
	print_debug(id_map_cache)
	
	level.load_in(levelJSON)
	area = level.areas[areaIndex]
	editor.set_level_area(area)
	
func unload():
	if area:
		area.unload(self)
		area = null
	
func reload():
	unload()
	area = level.areas[areaIndex]
	area.load_in(self, false)
		
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
		
func get_tile_from_godot_id(id):
	if id == -1:
		var tileset_id = 0
		var tileset = tileset_cache[tileset_id]
		var tile_id = 0
		return [str(tileset_id).pad_zeros(2), str(tile_id)]
	elif id == 2:
		var tileset_id = 2
		var tileset = tileset_cache[tileset_id]
		var tile_id = 0
		return [str(tileset_id).pad_zeros(2), str(tile_id)]
	elif id == 3:
		var tileset_id = 1
		var tileset = tileset_cache[tileset_id]
		var tile_id = 0
		return [str(tileset_id).pad_zeros(2), str(tile_id)]
		
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
		
func get_song(song_id: int):
	var level_songs : LevelSongs = load("res://assets/level_songs.tres")
	var song : LevelSong = load("res://assets/songs/" + level_songs.songs[song_id] + ".tres")
	return song
	
func get_sky(sky_id: int):
	var level_skies : LevelSongs = load("res://assets/level_skies.tres")
	var sky : SkyResource = load("res://assets/skies/" + level_skies.songs[sky_id] + ".tres")
	return sky
	
func get_parallax(background_id: int):
	var level_backgrounds : LevelSongs = load("res://assets/level_backgrounds.tres")
	var background : ParallaxResource = load("res://assets/backgrounds/" + level_backgrounds.songs[background_id] + ".tres")
	return background

func _process(delta):
	if game_mode == "Editing" && Input.is_action_just_pressed("switch_placement_mode"):
		if placement_mode == "Drag":
			placement_mode = "Tile"
		else:
			placement_mode = "Drag"
			
func decode_value(value: String):
	if value.is_valid_integer():
		return int(value)
	elif value.begins_with("V2"):
		value = value.trim_prefix("V2")
		var array_value = value.split("x")
		return Vector2(array_value[0], array_value[1])
	else:
		return str(value)

func parse_code(code: String):
	var result = {}
	var code_array = code.split("[")
	
	var level_settings_array = code_array[0].split(",")
	result.format_version = level_settings_array[0]
	result.name = level_settings_array[1].percent_decode()
	
	var area_array = code_array[1].split("~")
	area_array[0].erase(area_array[0].length() - 1, 1)
	
	var area_settings_array = area_array[0].split(",")
	result.areas = [{}]
	result.areas[0].settings = {}
	result.areas[0].settings.size = decode_value(area_settings_array[0])
	result.areas[0].settings.sky = decode_value(area_settings_array[1])
	result.areas[0].settings.background = decode_value(area_settings_array[2])
	result.areas[0].settings.music = decode_value(area_settings_array[3])
	
	var area_tiles_array = area_array[1].split(",")
	result.areas[0].foreground_tiles = []
	for tile in area_tiles_array:
		result.areas[0].foreground_tiles.append(tile)
		
	var area_background_tiles_array = area_array[2].split(",")
	result.areas[0].background_tiles = []
	for tile in area_background_tiles_array:
		result.areas[0].background_tiles.append(tile)
		
	var area_foreground_tiles_array = area_array[3].split(",")
	result.areas[0].very_foreground_tiles = []
	for tile in area_foreground_tiles_array:
		result.areas[0].very_foreground_tiles.append(tile)
		
	result.areas[0].objects = []
	if area_array.size() > 4:
		var objects_array = area_array[4].split("|")
		for object in objects_array:
			var object_array = object.split(",")
			var decoded_object = {}
			decoded_object.properties = {}
			decoded_object.id = object[0]
			decoded_object.name = id_map_cache.get(int(object[0]))
			decoded_object.properties.position = decode_value(object[1])
			decoded_object.properties.scale = decode_value(object[2])
			decoded_object.properties.rotation_degrees = decode_value(object[3])
			result.areas[0].objects.append(decoded_object)
	
	return result
