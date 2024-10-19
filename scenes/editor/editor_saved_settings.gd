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

func _init():
	var level_resource = LevelData.new()
	default_area = level_resource.areas[0]
