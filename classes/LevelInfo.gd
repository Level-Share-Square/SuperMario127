extends Node

class_name LevelInfo


const EMPTY_TIME_SCORE = -1 # idea: what if level creators could manually set this per shine, so there was a preset time to beat?
const OBJECT_ID_SHINE = 2 
const OBJECT_ID_STAR_COIN = -1 #get the correct id later

const VERSION : String = "0.0.1"

# this class stores all the info and savedata relating to a level that can be played from the level list 

var level_code : String # used for saving the level to disk

# trying to recreate a C# property here basically
var level_data_value : LevelData 
var level_data : LevelData setget set_level_data, get_level_data

# level info
var level_name : String = ""
var level_background : int = 0 

var shine_count : int = 0 #might change these to properties that return shine_details.size() and such
var shine_details : Array = [] setget set_shine_details, get_shine_details
var shine_details_value : Array = []

# the currently selected shine, will be used as an index to shine_details to show the information in the pause screen
# set by the shine_select screen, if it's a 0 or 1 star level it won't be set and will stay at -1
var selected_shine = -1

var star_coin_count : int = 0
# star coins need some sort of invisible property that will identify them uniquely
var star_coin_details : Array = [] setget set_star_coin_details, get_star_coin_details
var star_coin_details_value : Array = []

# save data 
var collected_shines : Array = [] # int array (int is the shine number)
var collected_star_coins : Array = [] # int array
var coin_score : int = 0
var time_scores : Array = [] # time_scores should probably be stored as the sum of delta while playing

func _init(passed_level_code : String = "") -> void:
	if passed_level_code == "":
		return

	level_code = passed_level_code
	level_data = LevelData.new()

	level_data.load_in(level_code)

	level_name = level_data.name
	level_background = level_data.areas[0].settings.sky # change this later so the area picked is the one that the player spawns in

	# loop through all objects in all areas to find the number of shines and star coins
	for area in level_data.areas:
		for object in area.objects:
			match(object.type_id):
				OBJECT_ID_SHINE:
					shine_count += 1
				OBJECT_ID_STAR_COIN:
					star_coin_count += 1

	# initialize time scores for each shine
	for _shine_number in range(shine_count):
		time_scores.append(EMPTY_TIME_SCORE)

# copy the data to both so functions all definitiely work right, idk if this is necessary, idk how gdscript "properties" work 
func set_level_data(new_value : LevelData):
	level_data = new_value
	level_data_value = new_value

func get_level_data() -> LevelData:
	if level_data_value == null:
		level_data_value = LevelData.new()
		level_data_value.load_in(level_code)
	return level_data_value

func set_shine_details(new_value : Array) -> void:
	shine_details = new_value 
	shine_details_value = new_value

func get_shine_details() -> Array:
	if shine_details_value.size() == 0 and shine_count > 0:
		shine_details_value = generate_shine_details()
	return shine_details_value

func set_star_coin_details(new_value : Array) -> void:
	star_coin_details = new_value 
	star_coin_details_value = new_value 

func get_star_coin_details() -> Array:
	if star_coin_details_value.size() == 0 and star_coin_count > 0:
		star_coin_details_value = generate_star_coin_details()
	return star_coin_details_value

# level_info is a reference, so we can just edit it directly
static func reset_save_data(level_info) -> void:
	level_info.collected_shines = []
	level_info.collected_star_coins = []
	level_info.coin_score = 0
	for shine_number in range(level_info.shine_count):
		level_info.time_scores[shine_number] = EMPTY_TIME_SCORE

func get_saveable_dictionary() -> Dictionary:
	# add saving shine details and star coin details
	var save_dictionary : Dictionary = \
	{
		"VERSION": VERSION,
		"level_code": level_code,
		"level_name": level_name,
		"level_background": level_background,
		"shine_count": shine_count,
		"star_coin_count": star_coin_count,

		"collected_shines": collected_shines,
		"collected_star_coins": collected_star_coins,
		"coin_score": coin_score,
		"time_scores": time_scores,
	}
	return save_dictionary

func load_from_dictionary(save_dictionary : Dictionary) -> void:
	level_code = save_dictionary["level_code"]
	level_name = save_dictionary["level_name"]
	level_background = save_dictionary["level_background"]
	shine_count = save_dictionary["shine_count"] 
	star_coin_count = save_dictionary["star_coin_count"]

	collected_shines = save_dictionary["collected_shines"]
	collected_star_coins = save_dictionary["collected_star_coins"]
	coin_score = save_dictionary["coin_score"]
	time_scores = save_dictionary["time_scores"]

func generate_shine_details() -> Array:
	var new_shine_details = []
	if get_level_data() == null: 
		return []

	for area in get_level_data().areas:
		for object in area.objects:
			if object.type_id == OBJECT_ID_SHINE:
				# these use weird indexed things because that's unfortunately just how stuff is stored before being loaded, this bit does what you'd expect, the values are the shines properties
				var shine_dictionary : Dictionary = \
				{
					"title": object.properties[5],
					"description": object.properties[6],
					"show_in_menu": object.properties[7],
					"id": object.properties[12],
				}
				new_shine_details.append(shine_dictionary)
	new_shine_details.sort_custom(self, "shine_details_sort")
	return new_shine_details

func shine_details_sort(item1 : Dictionary, item2 : Dictionary) -> bool:
	return item1["id"] < item2["id"]

func generate_star_coin_details() -> Array:
	return []

func set_shine_collected(shine_id : int) -> void:
	if not shine_id in collected_shines:
		collected_shines.append(shine_id)
	var _error_code = SavedLevels.save_level_by_index(SavedLevels.selected_level)

func set_star_coin_collected(star_coin_id : int) -> void:
	if !collected_star_coins.has(star_coin_id):
		collected_star_coins.append(star_coin_id)
	var _error_code = SavedLevels.save_level_by_index(SavedLevels.selected_level)

func get_level_sky_png() -> StreamTexture:
	var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	var background_resource = CurrentLevelData.background_cache[level_background]
	
	return background_resource.texture
