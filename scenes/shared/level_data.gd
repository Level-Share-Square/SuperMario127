extends Node

var level_data : LevelData
var area := 0
var area_plr_2 := 0

var object_cache := []
var background_cache := []
var foreground_cache := []

var enemies_instanced := 0

# The music IDs that can be randomly selected, can be found in the level code
var random_music := [ 1, 3, 18, 16 ]

var time_score : float = 0

# used to track if there's unsaved changes in the editor, specifically by the save and close buttons of the editor
var unsaved_editor_changes : bool = false

# incremented and used by shines/star coins to make the newest shine/star coin have a unique id (aka previous id + 1) 
var next_shine_id : int = 0
var next_star_coin_id : int = 0

# can be used by anything that needs to disable pausing for some time
var can_pause : bool = true

func pick_random_music() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var array_index = rng.randi_range(0, random_music.size() - 1)
	CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.music = random_music[array_index]

func _ready() -> void:
	set_process(false)

	level_data = LevelData.new()
	level_data.load_in(load("res://assets/level_data/template_level.tres").contents)
	pick_random_music()
	
	# These checks prevent memory leaks, and make it much quicker to reset the level
	if object_cache.size() == 0:
		var object_id_map : IdMap = preload("res://scenes/actors/objects/ids.tres")
		for object_id in object_id_map.ids:
			object_cache.append(load("res://scenes/actors/objects/" + object_id + "/" + object_id + ".tscn"))
	
	if background_cache.size() == 0:
		var background_id_mapper : IdMap = preload("res://scenes/shared/background/backgrounds/ids.tres")
		for background_id in background_id_mapper.ids:
			background_cache.append(load("res://scenes/shared/background/backgrounds/" + background_id + "/resource.tres"))
	
	if foreground_cache.size() == 0:
		var foreground_id_mapper : IdMap = preload("res://scenes/shared/background/foregrounds/ids.tres")
		for foreground_id in foreground_id_mapper.ids:
			foreground_cache.append(load("res://scenes/shared/background/foregrounds/" + foreground_id + "/resource.tres"))

# for now, process is disabled by default, so the timer needs to be started manually, if process here is ever needed for something else, create a bool for this
func _process(delta):
	time_score += delta

func start_tracking_time_score():
	set_process(true)
	time_score = 0

func stop_tracking_time_score():
	set_process(false)
