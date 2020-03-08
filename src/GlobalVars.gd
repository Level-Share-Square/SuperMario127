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
var level := Level.new()
var area : LevelArea
var editor := LevelEditor.new()

var is_tile := true
var selected_object_type : String
var selected_tile_id := 0
var selected_tileset_id := 1

func _ready():
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
	var level_tilesets : LevelTilesets = load("res://assets/level_tilesets.tres")
	var tileset : LevelTileset = load("res://assets/tilesets/" + level_tilesets.tilesets[tileset_id] + ".tres")
	if tile_id == 0:
		return tileset.block_tile_id
	elif tile_id == 1:
		return tileset.slab_tile_id
	elif tile_id == 2:
		return tileset.left_slope_tile_id
	else:
		return tileset.right_slope_tile_id
		
func get_tile_from_godot_id(id):
	var level_tilesets : LevelTilesets = load("res://assets/level_tilesets.tres")
	if id == -1:
		var tileset_id = 0
		var tileset : LevelTileset = load("res://assets/tilesets/" + level_tilesets.tilesets[tileset_id] + ".tres")
		var tile_id = 0
		return [str(tileset_id).pad_zeros(3), str(tile_id)]
	elif id == 2:
		var tileset_id = 2
		var tileset : LevelTileset = load("res://assets/tilesets/" + level_tilesets.tilesets[tileset_id] + ".tres")
		var tile_id = 0
		return [str(tileset_id).pad_zeros(3), str(tile_id)]
	elif id == 3:
		var tileset_id = 1
		var tileset : LevelTileset = load("res://assets/tilesets/" + level_tilesets.tilesets[tileset_id] + ".tres")
		var tile_id = 0
		return [str(tileset_id).pad_zeros(3), str(tile_id)]
		
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
