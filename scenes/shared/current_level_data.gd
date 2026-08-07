extends Node


const DEFAULT_CODE_PATH: String = "res://level/default_level.tres"
const DEFAULT_AREA_PATH: String = "res://level/default_area.tres"
const DEFAULT_NAME: String = "My Level"
const DEFAULT_AUTHOR: String = "Unknown"
const DEFAULT_DESCRIPTION: String = "This level has no description."
const DEFAULT_THUMBNAIL_URL: String = ""


var level_id: String
var working_folder: String = level_list_util.BASE_FOLDER
var hub_level: String = ""
var is_campaign: bool = false

var level_transition_data: Dictionary
var hub_return_data: Dictionary
var shine_kickout_data: Dictionary

var level_metadata: LevelMetadata
# Editor Data
var editor_data: EditorData
# Array of AreaHeader
var area_headers: Array
# Array of MissionData
var mission_data: Array

# Save file
var selected_file: int = -1
var save_data: LevelSaveData

var loaded_areas: Dictionary = {}

var area_id: int = -1
var current_area: AreaData

var current_mission_id: String = ""
var current_mission: MissionData

var enemies_instanced: int = 0

var vars: LevelVars = LevelVars.new()
var checkpoint_data: CheckpointData = CheckpointData.new()

var time_score_paused: bool
var time_score: float = 0

# used to track if there's unsaved changes in the editor, specifically by the save and close buttons of the editor
var unsaved_editor_changes: bool = false

var shine_progression: bool = false

# incremented and used by shines/star coins to make the newest shine/star coin have a unique id (aka previous id + 1) 
var next_shine_id: int = 0
var next_star_coin_id: int = 0

# can be used by anything that needs to disable pausing for some time
var can_pause: bool = true

# Cached objects and backgrounds 
# TODO: test if godot caching can replace these
var object_id_map: IdMap
var background_id_mapper: IdMap
var foreground_id_mapper: IdMap

var object_cache := []
var background_cache := []
var foreground_cache := []


signal finished(result)


#var thread : Thread
func _init() -> void:
	# since the time score is incremented here, it must keep incrementing while paused
	pause_mode = PAUSE_MODE_PROCESS
	set_process(false)
	
	object_id_map = preload("res://scenes/actors/objects/ids.tres")
	background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")
	
	object_cache.resize(object_id_map.ids.size())
	background_cache.resize(background_id_mapper.ids.size())
	foreground_cache.resize(foreground_id_mapper.ids.size())
	
	#thread = Thread.new()
	#thread.start(self, "create_cache")


# for now, process is disabled by default, so the timer needs to be started manually, if process here is ever needed for something else, create a bool for this
func _process(delta: float) -> void:
	if not time_score_paused:
		time_score += delta


## loading
func load_level_metadata(code: String) -> void:
	code = LevelCodeTokenizer.splice_level(code)
	code = LevelCodeTokenizer.splice_metadata(code)
	level_metadata = LevelCodeDeserializer.deserialize_level_metadata_code(code)
	save_data = LevelSaveData.new(level_id, working_folder, level_metadata.collectible_data)


func load_level_headers(code: String) -> void:
	if code.substr(0, 2) != "[{":
		convert_and_load_level(code)
		return
	
	load_level_metadata(code)
	
	code = LevelCodeTokenizer.splice_level(code)
	
	var components_code = LevelCodeTokenizer.splice_level_components(code)
	var editor_data_code = components_code[1]
	
	editor_data = LevelCodeDeserializer.deserialize_editor_data(editor_data_code)
	
	area_headers.clear()
	# load area headers
	var area_codes: PoolStringArray = LevelCodeTokenizer.splice_areas(components_code[0])
	for area_code in area_codes:
		var area_header: AreaHeader = LevelCodeDeserializer.deserialize_area_header_code(area_code)
		area_headers.append(area_header)


func switch_to_area(new_area_id: int, always_reload: bool = true, keep_old_loaded: bool = false) -> void:
	if not keep_old_loaded:
		unload_level_area(area_id)
	
	area_id = new_area_id
	
	current_area = load_level_area(area_id, always_reload)


func unload_all_but_current_area() -> void:
	for loaded_area_id in loaded_areas.keys():
		if loaded_area_id != area_id:
			loaded_areas.erase(loaded_area_id)

func get_area_args() -> Dictionary:
	var args: Dictionary = {}
	for area_header in area_headers:
		area_header = area_header as AreaHeader
		
		args[area_headers.find(area_header)] = area_header.name
	return args

func load_level_area(load_area_id: int, always_reload: bool = false) -> AreaData:
	if not always_reload:
		if not loaded_areas.has(load_area_id):
			var area_code: String = area_headers[area_id].area_code
			loaded_areas[load_area_id] = LevelCodeDeserializer.deserialize_area_code(area_code)
		else:
			print("Area %s is already loaded!" % str(area_id))
	else:
		var area_code: String = area_headers[area_id].area_code
		loaded_areas[load_area_id] = LevelCodeDeserializer.deserialize_area_code(area_code)
	
	return loaded_areas[load_area_id]


func unload_level_area(unload_area_id: int) -> void:
	loaded_areas.erase(unload_area_id)


# conversion
func convert_and_load_level(code: String) -> void:
	var level_data: LevelDataOld = LevelDataOld.new(code)
	level_data.load_in(code)
	
	var container: LevelDataContainer = conversion_util.get_new_level_data_from_old_data(level_data)
	level_metadata = container.level_metadata
	editor_data = container.editor_data
	area_headers = container.area_headers


func convert_old_code_to_new(code: String) -> String:
	var level_data: LevelDataOld = LevelDataOld.new(code)
	level_data.load_in(code)
#		return ""
	
	var container: LevelDataContainer = conversion_util.get_new_level_data_from_old_data(level_data)
	LevelCodeHandler.recalculate_level_collectible_counts(container)
	return LevelCodeSerializer.serialize_level_data(container)


## campaign
func is_hub_level() -> bool:
	return is_campaign and level_id == hub_level


func is_playing_hub_level() -> bool:
	return is_hub_level() and is_playing_campaign()


func is_playing_campaign() -> bool:
	return is_campaign and selected_file > -1


func get_meta_dict() -> Dictionary:
	var save_folder: String = level_list_util.get_save_folder(working_folder, selected_file)
	return save_meta_util.load_meta_file(save_folder)


func get_meta_collectibles() -> Dictionary:
	var meta_dict: Dictionary = get_meta_dict()
	return save_meta_util.get_collectible_totals(meta_dict)


## caching
func get_cached_object(index: int):
	if object_cache[index] != null:
		return object_cache[index]
	
	var key: String = object_id_map.ids[index]
	var path: String = "res://scenes/actors/objects/" + key + "/" + key + ".tscn"
	
	object_cache[index] = ResourceLoader.load(path)
	return object_cache[index]


func get_cached_background(index: int):
	if background_cache.size() <= index or abs(index) > background_cache.size()-1:
		index = 0
	if background_cache[index] != null:
		return background_cache[index]
	
	var key: String = background_id_mapper.ids[index]
	var path: String = "res://scenes/shared/background/backgrounds/" + key + "/resource.tres"
	
	background_cache[index] = ResourceLoader.load(path)
	return background_cache[index]


func get_cached_foreground(index: int):
	if foreground_cache.size() <= index or abs(index) > foreground_cache.size()-1:
		index = 0
	if foreground_cache[index] != null:
		return foreground_cache[index]
	
	var key: String = foreground_id_mapper.ids[index]
	var path: String = "res://scenes/shared/background/foregrounds/" + key + "/resource.tres"
	
	foreground_cache[index] = ResourceLoader.load(path)
	return foreground_cache[index]


## time score
func reset_time_score():
	time_score = 0


func start_time_score():
	reset_time_score()
	unpause_time_score()


func set_time_score_paused(paused: bool):
	time_score_paused = paused


func unpause_time_score():
	time_score_paused = false


func pause_time_score():
	time_score_paused = true


# TODO: star coins need new ID logic with the addition of missions
func get_new_star_coin_id() -> int:
	return 0
#	var new_id = 0
#	for area in CurrentLevelData.level_data.areas:
#		for object in area.objects:
#			if object.type_id == 52:
#				last_star_coin_id += 1
#	return last_star_coin_id


func set_checkpoint_ids():
	var checkpoint_id = 0
#	for area in CurrentLevelData.level_data.areas:
#		for object in area.objects:
#			if object.type_id == 82:
#				object.properties.resize(10)
#				object.properties[9] = checkpoint_id
#				checkpoint_id += 1
	return checkpoint_id
