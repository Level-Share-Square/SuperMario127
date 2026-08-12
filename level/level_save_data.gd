class_name LevelSaveData
extends Resource


const VERSION : String = "0.1.0"
const EMPTY_TIME_SCORE = -1

var level_id: String
var level_folder: String

var _total_mission_count: int = -1
var _total_star_coins: int = -1
var _completed_missions: Array = []
var _collected_star_coins: PoolStringArray = [] # element is the star coin uuid
var _time_scores: Dictionary = {} # time_scores should probably be stored as the sum of delta while playing, keys are same as completed_missions
var _activated_fludds: Array = [false, false, false]

var collectible_data: CollectibleData # only for use in conversion

func get_save_path(selected_file: int = -3) -> String:
	if selected_file == -3:
		selected_file = CurrentLevelData.selected_file
	return level_list_util.get_level_save_path(level_id, level_folder, selected_file)


func _init(s_level_id: String, s_level_folder: String, s_collectible_data: CollectibleData = null) -> void:
	level_id = s_level_id
	level_folder = s_level_folder
	collectible_data = s_collectible_data
	load_save_from_dictionary(level_list_util.load_level_save_file(get_save_path()))

func reset_save_data():
	_completed_missions = []
	_collected_star_coins = []
	_time_scores = {}
	_activated_fludds = [false, false, false]
	_total_mission_count = -1
	_total_star_coins = -1
	level_list_util.save_level_save_file(get_save_file_dictionary(), get_save_path())

func get_save_file_dictionary() -> Dictionary:
	return {
		"VERSION": VERSION,
		"completed_missions": _completed_missions,
		"collected_star_coins": _collected_star_coins,
		"time_scores": _time_scores,
		"activated_fludds": _activated_fludds,
		"total_missions": _total_mission_count,
		"total_star_coins": _total_star_coins,
	}


func load_save_from_dictionary(save_dictionary: Dictionary):
	if save_dictionary.empty():
		return
	
	if save_dictionary["VERSION"] == VERSION:
		load_save_0_1_0(save_dictionary)
	else:
		load_save_0_1_0(convert_save_to_0_1_0(save_dictionary))


func set_mission_complete(mission_uuid: String, save_to_disk: bool = true) -> void:
	if mission_uuid in _completed_missions: return
	_completed_missions.append(mission_uuid)
	if save_to_disk:
		level_list_util.save_level_save_file(get_save_file_dictionary(), get_save_path())


func set_star_coin_collected(star_coin_uuid: String, save_to_disk: bool = true) -> void:
	if star_coin_uuid in _collected_star_coins: return
	_collected_star_coins.append(star_coin_uuid)
	if save_to_disk:
		level_list_util.save_level_save_file(get_save_file_dictionary(), get_save_path())


func set_fludd_activated(fludd_id: int, save_to_disk: bool = true) -> void:
	_activated_fludds[fludd_id] = true
	if save_to_disk:
		level_list_util.save_level_save_file(get_save_file_dictionary(), get_save_path())

func set_total_mission_count(amount: int):
	_total_mission_count = amount
	level_list_util.save_level_save_file(get_save_file_dictionary(), get_save_path())
	
func set_total_star_coin_count(amount: int):
	_total_star_coins = amount
	level_list_util.save_level_save_file(get_save_file_dictionary(), get_save_path())

func get_time_score_dictionary() -> Dictionary:
	return _time_scores
	
func get_time_score(mission_uuid: String):
	return _time_scores.get(mission_uuid, 0)

func update_time_and_coin_score(mission_uuid: String, save_to_disk: bool = true):
	var new_time_score = CurrentLevelData.time_score
	
	if is_new_record(mission_uuid):
		_time_scores[mission_uuid] = new_time_score
	
	if save_to_disk:
		level_list_util.save_level_save_file(get_save_file_dictionary(), get_save_path())


func is_new_record(mission_uuid: String) -> bool:
	var new_time_score = CurrentLevelData.time_score
	if new_time_score < _time_scores.get(mission_uuid, -1) or _time_scores.get(mission_uuid, -1) == EMPTY_TIME_SCORE:
		return true
	return false


func is_mission_complete(mission_uuid: String) -> bool:
	return mission_uuid in _completed_missions


func is_star_coin_collected(star_coin_uuid: String) -> bool:
	return star_coin_uuid in _collected_star_coins


func is_fully_completed() -> bool:
	return all_missions_completed() and all_star_coins_collected()


func get_total_mission_count() -> int:
	return _total_mission_count


func get_completed_mission_count() -> int:
	return _completed_missions.size()


func all_missions_completed() -> bool:
	return _completed_missions.size() == get_total_mission_count()


func get_total_star_coin_count() -> int:
	return _total_star_coins


func get_collected_star_coin_count() -> int:
	return _collected_star_coins.size()


func all_star_coins_collected() -> bool:
	return _collected_star_coins.size() == get_total_star_coin_count()
	

func get_completed_missions() -> Array:
	return _completed_missions


func load_save_0_1_0(save_dictionary: Dictionary):
	_completed_missions = save_dictionary["completed_missions"]
	_collected_star_coins = save_dictionary["collected_star_coins"]
	_time_scores = save_dictionary["time_scores"]
	_activated_fludds = save_dictionary["activated_fludds"]
	_total_mission_count = save_dictionary["total_missions"]
	_total_star_coins = save_dictionary["total_star_coins"]


func convert_save_to_0_1_0(save_dictionary: Dictionary) -> Dictionary:
	var new_save_dict: Dictionary = {}

	# Shine data to mission completion data
	var mission_array: Array = []
	for shine in save_dictionary["collected_shines"]:
		var shine_id: int = int(shine)
		if save_dictionary.get("collected_shines", {}).get(shine, false):
			var mission_uuid: String = collectible_data.mission_data[shine_id].mission_uuid
			mission_array.append(mission_uuid)

	new_save_dict.get_or_add("completed_missions", mission_array)

	# star coin data
	var star_coin_array: Array = []
	for star_coin in save_dictionary["collected_star_coins"]:
		var star_coin_id: int = int(star_coin)
		if save_dictionary.get("collected_star_coins", {}).get(star_coin, false):
			var star_coin_uuid: String = collectible_data.star_coin_data[star_coin_id].star_coin_uuid
			star_coin_array.append(star_coin_uuid)

	new_save_dict.get_or_add("collected_star_coins", star_coin_array)

	# time scores
	var time_score_dict: Dictionary = {}
	for shine in save_dictionary["time_scores"]:
		var shine_id: int = int(shine)
		var mission_uuid: String = collectible_data.mission_data[shine_id].mission_uuid
		time_score_dict.get_or_add(mission_uuid, save_dictionary.get("time_scores", {}).get(shine, -1))

	new_save_dict.get_or_add("time_scores", time_score_dict)
	new_save_dict.get_or_add("activated_fludds", save_dictionary.get("activated_fludds", [false, false, false])) 
	new_save_dict.get_or_add("total_missions", collectible_data.mission_data.size())
	new_save_dict.get_or_add("total_star_coins", collectible_data.star_coin_data.size())

	return new_save_dict
