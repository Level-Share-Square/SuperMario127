extends Node

var number_of_boxes := 7
var selected_box := 0
var zoom_level := 1.0
var layer := 1
var layers_transparent := false
var show_grid := true

var tileset_palettes = []

var layout_ids = [
]

func _init():
	var starting_toolbar = load("res://scenes/editor/starting_toolbar.tres")
	for index in range(number_of_boxes):
		layout_ids.append(starting_toolbar.ids[index])
