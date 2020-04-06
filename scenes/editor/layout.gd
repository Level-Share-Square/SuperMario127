extends Node

var number_of_boxes := 7

var ids = [
]

func _init():
	var starting_toolbar = load("res://scenes/editor/starting_toolbar.tres")
	for index in range(number_of_boxes):
		ids.append(starting_toolbar.ids[index])
