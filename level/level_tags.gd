class_name LevelTags
extends LevelDataResource

export var teleport_tags: Array
export var dialogue_tags: Array
export var liquid_tags: Array
export var key_tags: Array

var key_object_map: Dictionary = {}

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

func get_key_args() -> Dictionary:
	var args: Dictionary = {}
	for tag in key_tags:
		args[tag] = tag
	return args

func find_key_index(id: String, key_data: KeyData) -> int:
	var i: int = 0
	if not key_object_map.has(id): return -1
	for data in key_object_map[id]:
		if key_data.is_equal(data):
			return i
	return -1

func _init(_teleport_tags: Array = [], _dialogue_tags: Array = [], _liquid_tags: Array = [], _key_tags: Array = []):
	teleport_tags = _teleport_tags
	dialogue_tags = _dialogue_tags
	liquid_tags = _liquid_tags
	key_tags = _key_tags
