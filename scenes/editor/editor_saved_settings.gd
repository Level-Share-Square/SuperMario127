extends Node

var number_of_boxes := 10
var selected_box := 0
var zoom_level := 1.0
var layer := 1
var layers_transparent := false
var show_grid := true

var data_tiles = 0
var pinned_items : Array 

var tileset_loaded = false
var loading_tileset := false

var default_area : LevelArea

var layout_ids = [
]

var layout_palettes = [
	
]

func _init():
	var level_resource = LevelData.new()
	default_area = level_resource.areas[0]
	
	var starting_toolbar = load("res://scenes/editor/starting_toolbar.tres")
	for index in range(number_of_boxes):
		layout_ids.append(starting_toolbar.ids[index])
		layout_palettes.append(0)
