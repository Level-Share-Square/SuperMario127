extends Node

class_name LevelInfo

const EMPTY_TIME_SCORE = -1 # idea: what if level creators could manually set this per shine, so there was a preset time to beat?
const OBJECT_ID_SHINE = 2 
const OBJECT_ID_STAR_COIN = 52

const VERSION : String = "0.0.3"

# this class stores all the info and savedata relating to a level that can be played from the level list 

var level_code : String # used for saving the level to disk

# i'm not quite sure what the idea was behind making it load
# the level data twice, but i went and removed that
var level_data : LevelData

# level info
var level_name : String = ""
var level_author : String = ""
var level_description : String = ""
var thumbnail_url : String = ""

var spawn_area : int = 0
var shine_details : Array = []
var star_coin_details : Array = []

# the currently selected shine, will be used as an index to shine_details to show the information in the pause screen
# set by the shine_select screen, if it's a 0 or 1 star level it won't be set and will stay at -1
var selected_shine = -1

# save data 
var collected_shines : Dictionary = {} # key is the shine id (in a string, because json), value is a bool, either false or true
var collected_star_coins : Dictionary = {} # same as collected_shines
var coin_score : int = 0
var time_scores : Dictionary = {} # time_scores should probably be stored as the sum of delta while playing, keys are same as collected_shines
var activated_fludds : Array = [false, false, false]

func _init(passed_level_code : String = "") -> void:
	if passed_level_code == "":
		return

	level_code = passed_level_code
	level_data = LevelData.new(level_code)
	
	level_name = level_data.name
	level_author = level_data.author
	level_description = level_data.description
	thumbnail_url = level_data.thumbnail_url

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
						"color": object.properties[11].to_rgba32(),
						"id": object.properties[12],
						"do_kick_out": object.properties[13]
					}
					# Lol band aid
					if object.properties.size() > 13:
						shine_dictionary["sort_order"] = object.properties[14]
					else:
						shine_dictionary["sort_order"] = object.properties[12]
					shine_details.append(shine_dictionary)

					# initialize collected_shines and time_scores
					collected_shines[str(shine_dictionary["id"])] = false 
					time_scores[str(shine_dictionary["id"])] = EMPTY_TIME_SCORE
				OBJECT_ID_STAR_COIN:
					var star_coin_id = object.properties[5]
					star_coin_details.append(star_coin_id)

					# initialize collected star coins
					collected_star_coins[str(star_coin_id)] = false

			shine_details.sort_custom(self, "shine_sort")
			star_coin_details.sort()

func reset_save_data(delete_file: bool = true) -> void:
	for collected_shine in collected_shines:
		collected_shines[collected_shine] = false
	for collected_star_coin in collected_star_coins:
		collected_star_coins[collected_star_coin] = false
	activated_fludds = [false, false, false]
	coin_score = 0
	for key in time_scores.keys():
		time_scores[key] = EMPTY_TIME_SCORE
	
	if delete_file and saved_levels_util.file_exists(get_save_path()):
		saved_levels_util.delete_file(get_save_path())
	#var _error_code = Singleton.SavedLevels.save_level_by_index(Singleton.SavedLevels.selected_level)


### new functions designed to save separately to the level code
func get_save_path() -> String:
	return saved_levels_util.get_level_save_path(Singleton.CurrentLevelData.level_id, Singleton.CurrentLevelData.working_folder)

func get_save_file_dictionary() -> Dictionary:
	var save_dictionary : Dictionary = \
	{
		"VERSION": VERSION,
		"spawn_area": spawn_area,
		"shine_details": shine_details,
		"star_coin_details": star_coin_details,

		"collected_shines": collected_shines,
		"collected_star_coins": collected_star_coins,
		"coin_score": coin_score,
		"time_scores": time_scores,
		"activated_fludds": activated_fludds
	}
	return save_dictionary

func load_save_from_dictionary(save_dictionary: Dictionary):
	match save_dictionary["VERSION"]:
		"0.0.3":
			load_save_0_0_3(save_dictionary)


### DEPRECATED ###################################
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
		"activated_fludds": activated_fludds
	}
	return save_dictionary

func load_from_dictionary(save_dictionary : Dictionary) -> void:
	match save_dictionary["VERSION"]:
		"0.0.1":
			load_level_0_0_1(save_dictionary)
		"0.0.2":
			load_level_0_0_2(save_dictionary)
###################################################

static func shine_sort(item1 : Dictionary, item2 : Dictionary) -> bool:
	return item1["sort_order"] < item2["sort_order"]

func set_shine_collected(shine_id : int, save_to_disk : bool = true) -> void:
	collected_shines[str(shine_id)] = true
	if save_to_disk:
		saved_levels_util.save_level_save_file(get_save_file_dictionary(), get_save_path())

func set_star_coin_collected(star_coin_id : int, save_to_disk : bool = true) -> void:
	collected_star_coins[str(star_coin_id)] = true
	if save_to_disk:
		saved_levels_util.save_level_save_file(get_save_file_dictionary(), get_save_path())

func set_fludd_activated(fludd_id : int, save_to_disk : bool = true) -> void:
	activated_fludds[fludd_id] = true
	if save_to_disk:
		saved_levels_util.save_level_save_file(get_save_file_dictionary(), get_save_path())

func update_time_and_coin_score(shine_id : int, save_to_disk : bool = true):
	var new_coin_score = Singleton.CurrentLevelData.level_data.vars.coins_collected
	var new_time_score = Singleton.CurrentLevelData.time_score

	if new_coin_score > coin_score:
		coin_score = new_coin_score 

	if new_time_score < time_scores[str(shine_id)] or time_scores[str(shine_id)] == EMPTY_TIME_SCORE:
		time_scores[str(shine_id)] = new_time_score
		Singleton2.save_ghost = true
	if save_to_disk:
		saved_levels_util.save_level_save_file(get_save_file_dictionary(), get_save_path())

func get_level_background_texture() -> StreamTexture:
	var level_background = level_data.areas[spawn_area].settings.sky 
	var background_resource = Singleton.CurrentLevelData.background_cache[level_background]
	return background_resource.texture
	
func get_level_background_modulate() -> Color:
	var level_background = level_data.areas[spawn_area].settings.sky
	var background_resource = Singleton.CurrentLevelData.background_cache[level_background]
	return background_resource.parallax_modulate

func get_level_foreground_texture() -> StreamTexture:
	var level_foreground = level_data.areas[spawn_area].settings.background
	var foreground_resource = Singleton.CurrentLevelData.foreground_cache[level_foreground]
	var palette = level_data.areas[spawn_area].settings.background_palette
	
	if palette == 0:
		return foreground_resource.preview
	else:
		return foreground_resource.palettes[palette - 1]

func get_collectible_counts() -> Dictionary:
	var dict = {
		"total_shines": 0,
		"collected_shines": 0,
		
		"total_star_coins": 0,
		"collected_star_coins": 0,
		
		"total_collectibles": 0,
		"total_collected": 0,
	}
	# Only count shine sprites that have show_in_menu on
	for details in shine_details:
		dict["total_shines"] += 1
		if collected_shines[str(details["id"])]:
			dict["collected_shines"] += 1
	dict["total_star_coins"] = collected_star_coins.size()
	dict["collected_star_coins"] = collected_star_coins.values().count(true)
	
	dict["total_collectibles"] = dict["total_shines"] + dict["total_star_coins"]
	dict["total_collected"] = dict["collected_shines"] + dict["collected_star_coins"]
	
	return dict

# have you collected all shine sprites and star coins in the level?
func is_fully_completed() -> bool:
	var collectible_counts = get_collectible_counts()
	return collectible_counts["total_collected"] >= collectible_counts["total_collectibles"]

static func generate_time_string(time : float) -> String:
	# converting to int to use modulo, then doing abs to avoid problems with negative results, then back to int because that's the type
	var minutes : int = int(abs(int(time / 60) % 99)) # mod this by 99 so if you somehow take 100+ minutes at least the time will wrap around instead of breaking the display
	var seconds : int = int(abs(int(time) % 60))
	var centiseconds : int = int(abs(int(time * 100) % 100))

	return "%s%s:%s%s.%s%s" % [pad_timevalue(minutes), minutes, pad_timevalue(seconds), seconds, pad_timevalue(centiseconds), centiseconds]

static func pad_timevalue(timevalue : int) -> String:
	return "0" if timevalue < 10 else ""

# LevelInfo dictionary loading functions for different versions start here
func load_level_0_0_1(save_dictionary : Dictionary):
	print("01")
	level_code = save_dictionary["level_code"]
	level_name = save_dictionary["level_name"]

	collected_shines = save_dictionary["collected_shines"]
	collected_star_coins = save_dictionary["collected_star_coins"]
	coin_score = save_dictionary["coin_score"]
	time_scores = save_dictionary["time_scores"]

func load_level_0_0_2(save_dictionary : Dictionary):
	load_level_0_0_1(save_dictionary)
	
	spawn_area = save_dictionary["spawn_area"]
	shine_details = save_dictionary["shine_details"] 
	star_coin_details = save_dictionary["star_coin_details"]
	activated_fludds = save_dictionary["activated_fludds"]


func load_save_0_0_3(save_dictionary: Dictionary):
	collected_shines = save_dictionary["collected_shines"]
	collected_star_coins = save_dictionary["collected_star_coins"]
	coin_score = save_dictionary["coin_score"]
	time_scores = save_dictionary["time_scores"]

	spawn_area = save_dictionary["spawn_area"]
	shine_details = save_dictionary["shine_details"] 
	star_coin_details = save_dictionary["star_coin_details"]
	activated_fludds = save_dictionary["activated_fludds"]
