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

var default_level : LevelDataOld
var default_area : LevelAreaOld

func _init():
	default_level = ValidityChecker.new()
	default_level.check_validity()
	default_area = default_level.areas[0]
