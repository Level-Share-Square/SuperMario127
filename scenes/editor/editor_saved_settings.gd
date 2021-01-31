extends Node

var number_of_boxes := 7
var selected_box := 0
var zoom_level := 1.0
var layer := 1
var layers_transparent := false
var show_grid := true

var tileset_palettes = []
var data_tiles = 0
var tiles_resource : TileSet

var tileset_loaded = false

var default_area : LevelArea
var stored_window_scale := 1

var layout_ids = [
]

var layout_palettes = [
	
]

func _init():
	var level_resource = LevelData.new()
	var default_level = load("res://assets/level_data/template_level.tres").contents
	level_resource.load_in(default_level)
	default_area = level_resource.areas[0]
	
	tiles_resource = ResourceLoader.load("user://tiles.res", "TileSet")
	var starting_toolbar = load("res://scenes/editor/starting_toolbar.tres")
	for index in range(number_of_boxes):
		layout_ids.append(starting_toolbar.ids[index])
		layout_palettes.append(0)
