extends Node

var level_data : LevelData
var area := 0

func _ready():
	level_data = LevelData.new()
	level_data.load_in(load("res://assets/level_data/template_level.tres").contents)
