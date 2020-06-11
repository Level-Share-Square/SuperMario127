extends Node

var level_data : LevelData
var area := 0
var area_plr_2 := 0

var object_cache = []
var background_cache = []
var foreground_cache = []

var enemies_instanced = 0

func _ready():
	level_data = LevelData.new()
	level_data.load_in(load("res://assets/level_data/template_level.tres").contents)

	var object_id_map : IdMap = load("res://scenes/actors/objects/ids.tres")
	for object_id in object_id_map.ids:
		object_cache.append(load("res://scenes/actors/objects/" + object_id + "/" + object_id + ".tscn"))

	var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	for background_id in background_id_mapper.ids:
		background_cache.append(load("res://scenes/shared/background/backgrounds/" + background_id + "/resource.tres"))
		
	var foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")
	for foreground_id in foreground_id_mapper.ids:
		foreground_cache.append(load("res://scenes/shared/background/foregrounds/" + foreground_id + "/resource.tres"))
		
