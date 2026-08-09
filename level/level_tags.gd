class_name LevelTags
extends LevelDataResource

export var teleport_tags: Array
export var dialogue_tags: Array
export var liquid_tags: Array

func get_teleport_args() -> Dictionary:
	var args: Dictionary = {}
	for tag in teleport_tags:
		args[tag] = tag
	return args
	
func get_dialogue_args() -> Dictionary:
	var args: Dictionary = {}
	for tag in dialogue_tags:
		args[tag] = tag
	return args
	
func get_liquid_args() -> Dictionary:
	var args: Dictionary = {}
	for tag in liquid_tags:
		args[tag] = tag
	return args

func _init(_teleport_tags: Array = [], _dialogue_tags: Array = [], _liquid_tags: Array = []):
	teleport_tags = _teleport_tags
	dialogue_tags = _dialogue_tags
	liquid_tags = _liquid_tags
