extends Node2D

export var game_mode = "Editing"
export var control_mode = "Normal"
export var gravity = Vector2(0, 7.82)
export var max_gravity_velocity = Vector2(950, 950)
export var levelJSON : Resource
export var areaIndex := 0
export var placement_mode = "Drag"
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

func _process(delta):
	if game_mode == "Editing" && Input.is_action_just_pressed("switch_placement_mode"):
		if placement_mode == "Drag":
			placement_mode = "Tile"
		else:
			placement_mode = "Drag"
