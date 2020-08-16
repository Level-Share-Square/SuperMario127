extends Node

class_name LevelInfo

const EMPTY_TIME_SCORE = -1 # idea: what if level creators could manually set this per shine, so there was a preset time to beat?
const OBJECT_ID_SHINE = 2 
const OBJECT_ID_STAR_COIN = -1 #get the correct id later

const VERSION : String = "0.0.2"

# this class stores all the info and savedata relating to a level that can be played from the level list 

var level_code : String # used for saving the level to disk

# trying to recreate a C# property here basically
# NOTE: ALWAYS call get_level_data() within LevelInfo.gd, Godot won't call the getter within the same script
var level_data_value : LevelData 
var level_data : LevelData setget set_level_data, get_level_data

# level info
var level_name : String = ""
var spawn_area : int = 0
var shine_details : Array = []
var star_coin_details : Array = []

# the currently selected shine, will be used as an index to shine_details to show the information in the pause screen
# set by the shine_select screen, if it's a 0 or 1 star level it won't be set and will stay at -1
var selected_shine = -1

# save data 
var collected_shines : Dictionary = {} # key is the shine id, value is a bool, either false or true
var collected_star_coins : Dictionary = {} # same as collected_shines
var coin_score : int = 0
var time_scores : Dictionary = {} # time_scores should probably be stored as the sum of delta while playing

func _init(passed_level_code : String = "") -> void:
	if passed_level_code == "":
		return

	level_code = passed_level_code
	level_data = LevelData.new()

	level_data.load_in(level_code)

	level_name = level_data.name

	# loop through all objects in all areas to find the number of shines and star coins
	for area in level_data.areas:
		for object in area.objects:
			match(object.type_id):
				OBJECT_ID_SHINE:
					# these use weird indexed things because that's unfortunately just how stuff is stored before being loaded, this bit does what you'd expect, the values are the shines properties
					var shine_dictionary : Dictionary = \
					{
						"title": object.properties[5],
						"description": object.properties[6],
						"show_in_menu": object.properties[7],
						"color": object.properties[11],
						"id": object.properties[12],
					}
					shine_details.append(shine_dictionary)
					shine_details.sort_custom(self, "collectible_with_id_sort")

					# initialize collected_shines and time_scores
					collected_shines[str(shine_dictionary["id"])] = false 
					time_scores[str(shine_dictionary["id"])] = EMPTY_TIME_SCORE
					print(time_scores)
				OBJECT_ID_STAR_COIN:
					pass

func set_level_data(new_value : LevelData):
	level_data_value = new_value

# lazy loading setup, this is why the property emulation is needed 
# also can't just do level_data == null as it causes a recursive call of get_level_data()
func get_level_data() -> LevelData:
	if level_data_value == null:
		level_data_value = LevelData.new()
		level_data_value.load_in(level_code)
	return level_data_value

func reset_save_data() -> void:
	collected_shines = {}
	collected_star_coins = {}
	coin_score = 0
	for key in time_scores.keys():
		time_scores[key] = EMPTY_TIME_SCORE

func get_saveable_dictionary() -> Dictionary:
	# add saving shine details and star coin details
	var save_dictionary : Dictionary = \
	{
		"VERSION": VERSION,
		"level_code": level_code,
		"level_name": level_name,
		"spawn_area": spawn_area,
		"shine_details": shine_details,
		"star_coin_details": star_coin_details,

		"collected_shines": collected_shines,
		"collected_star_coins": collected_star_coins,
		"coin_score": coin_score,
		"time_scores": time_scores,
	}
	return save_dictionary

func load_from_dictionary(save_dictionary : Dictionary) -> void:
	match save_dictionary["VERSION"]:
		"0.0.1":
			load_level_0_0_1(save_dictionary)
		"0.0.2":
			load_level_0_0_2(save_dictionary)

func collectible_with_id_sort(item1 : Dictionary, item2 : Dictionary) -> bool:
	return item1["id"] < item2["id"]

func set_shine_collected(shine_id : int, save_to_disk : bool = true) -> void:
	collected_shines[str(shine_id)] = true
	if save_to_disk:
		var _error_code = SavedLevels.save_level_by_index(SavedLevels.selected_level)

func set_star_coin_collected(star_coin_id : int, save_to_disk : bool = true) -> void:
	collected_star_coins[str(star_coin_id)] = true
	if save_to_disk:
		var _error_code = SavedLevels.save_level_by_index(SavedLevels.selected_level)

func update_time_and_coin_score(shine_id : int, save_to_disk : bool = true):
	var new_coin_score = CurrentLevelData.level_data.vars.coins_collected
	var new_time_score = CurrentLevelData.time_score

	if new_coin_score > coin_score:
		coin_score = new_coin_score 

	if new_time_score < time_scores[str(shine_id)] or time_scores[str(shine_id)] == EMPTY_TIME_SCORE:
		time_scores[str(shine_id)] = new_time_score

	if save_to_disk:
		var _error_code = SavedLevels.save_level_by_index(SavedLevels.selected_level)

func get_level_background_texture() -> StreamTexture:
	var level_background = get_level_data().areas[spawn_area].settings.sky 
	var background_resource = CurrentLevelData.background_cache[level_background]
	return background_resource.texture
	
func get_level_background_modulate() -> Color:
	var level_background = get_level_data().areas[spawn_area].settings.sky
	var background_resource = CurrentLevelData.background_cache[level_background]
	return background_resource.parallax_modulate

func get_level_foreground_texture() -> StreamTexture:
	var level_foreground = get_level_data().areas[spawn_area].settings.background
	var foreground_resource = CurrentLevelData.foreground_cache[level_foreground]
	return foreground_resource.preview

# LevelInfo dictionary loading functions for different versions start here
func load_level_0_0_1(save_dictionary : Dictionary):
	level_code = save_dictionary["level_code"]
	level_name = save_dictionary["level_name"]

	collected_shines = save_dictionary["collected_shines"]
	collected_star_coins = save_dictionary["collected_star_coins"]
	coin_score = save_dictionary["coin_score"]
	time_scores = save_dictionary["time_scores"]

func load_level_0_0_2(save_dictionary : Dictionary):
	level_code = save_dictionary["level_code"]
	level_name = save_dictionary["level_name"]
	spawn_area = save_dictionary["spawn_area"]
	shine_details = save_dictionary["shine_details"] 
	star_coin_details = save_dictionary["star_coin_details"]

	collected_shines = save_dictionary["collected_shines"]
	collected_star_coins = save_dictionary["collected_star_coins"]
	coin_score = save_dictionary["coin_score"]
	time_scores = save_dictionary["time_scores"]
