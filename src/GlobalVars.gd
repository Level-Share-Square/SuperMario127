extends Node2D

export var game_mode = "Editing"
export var control_mode = "Normal"
export var gravity = Vector2(0, 7.82)
export var max_gravity_velocity = Vector2(950, 950)
export var levelJSON : Resource
export var areaIndex := 0
var level := Level.new()
var area : LevelArea
var editor := LevelEditor.new()

var selected_tile := 1
var selected_tile_rect := Rect2(96, 0, 32, 32)

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
	area.load_in(self)
		
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
	
