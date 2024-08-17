extends Node

onready var thread = Thread.new()

var number_of_boxes := 10
var selected_box := 0
var zoom_level := 1.0
var layer := 1
var layers_transparent := false
var show_grid := true

var tileset_palettes = []
var data_tiles = 0
var tiles_resource : TileSet
var pinned_items : Array 

var tileset_loaded = false
var loading_tileset := false

var default_area : LevelArea

var layout_ids = [
]

var layout_palettes = [
	
]


func load_tileset(_userdata):
	var resource_loader := ResourceLoader.load_interactive("user://tiles.res", "TileSet")
	
	while resource_loader.poll() != ERR_FILE_EOF:
		pass
	
	tiles_resource = resource_loader.get_resource()
	loading_tileset = false
	print("gg")

func _init():
	var level_resource = LevelData.new()
	default_area = level_resource.areas[0]
	
	var starting_toolbar = load("res://scenes/editor/starting_toolbar.tres")
	for index in range(number_of_boxes):
		layout_ids.append(starting_toolbar.ids[index])
		layout_palettes.append(0)

func _ready():
	if ResourceLoader.exists("user://tiles.res"):
		loading_tileset = true
		thread.start(self, "load_tileset")
