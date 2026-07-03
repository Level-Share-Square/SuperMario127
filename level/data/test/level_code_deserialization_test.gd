extends Node2D


const TEST_CODE_PATH = "res://level/data/test/test_code.txt"
const PLAYER_PATH = preload("res://scenes/player/player.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	#var code = load_file()
	#var level = LevelCodeSerializer.deserialize_level_code(code)
	# for some FRICKING reason this already has an area in it so i delete it here :3 
	Singleton.CurrentLevelData.level_data.areas = []
	instance_debug_level()


func load_file():
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func instance_debug_level():
	# This whole funciton is a mess i have no idea how to do it right
	var TEST_CODE_PATH = "res://level/data/test/test_code.txt"
	var file = File.new()
	file.open(TEST_CODE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	var level = LevelCodeSerializer.deserialize_level_code(content)
	var instance = LevelDataInstancer.new()
	add_child(instance)
	instance.instance_level_data(level)
	var player = PLAYER_PATH.instance()
	get_tree().change_scene_to(PLAYER_PATH)

