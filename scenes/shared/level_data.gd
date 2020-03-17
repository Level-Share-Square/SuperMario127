extends Node

var level_data : LevelData

func _ready():
	level_data = LevelData.new()
	level_data.load_in(load("res://assets/level_data/test_level.tres").contents)
