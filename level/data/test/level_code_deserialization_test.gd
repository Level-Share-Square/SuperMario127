extends Node2D


const TEST_CODE_PATH = "res://level/data/test/test_code.txt"


# Called when the node enters the scene tree for the first time.
func _ready():
	#var code = load_file()
	#var level = LevelCodeSerializer.deserialize_level_code(code)
	instance_debug_level()


func load_file():
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func instance_debug_level():
	var TEST_CODE_PATH = "res://level/data/test/test_code.txt"
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	var level = LevelCodeSerializer.deserialize_level_code(content)
	var instance = LevelDataInstancer.new()
	instance.instance_level_data(level)
	get_tree().change_scene("res://scenes/player/player.tscn")
