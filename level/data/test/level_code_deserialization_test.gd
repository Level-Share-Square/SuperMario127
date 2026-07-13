extends Node2D


const TEST_CODE_PATH = "res://level/data/test/test_code.txt"
const PLAYER_PATH = preload("res://scenes/player/player.tscn")


func _ready():
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
	CurrentLevelData.load_level_headers(content)
	CurrentLevelData.load_level_area(0)
	get_tree().change_scene_to(PLAYER_PATH)

