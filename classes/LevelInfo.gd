extends Node

class_name LevelInfo

const INT_MAX = 9223372036854775807
const ID_SHINE = 2 
const ID_STAR_COIN = -1 #get the correct id later

# this class stores all the info and savedata relating to a level that can be played from the level list 

var level_code : String # used for saving the level to disk

# trying to recreate a C# property here basically
var level_data_value : LevelData 
var level_data : LevelData setget set_level_data, get_level_data

# level info
var level_name : String = ""
var level_background : int = 0 
var shine_count : int = 0 
var star_coin_count : int = 0

# save data 
var collected_shines : int = 0 # just realised these need to be Arrays or something, oops
var collected_star_coins : int = 0
var coin_score : int = 0
var time_scores : Array = [] # time_scores should probably be stored as the sum of delta while playing

func _init(passed_level_code : String = "") -> void:
	if passed_level_code == "":
		return

	level_code = passed_level_code
	level_data = LevelData.new()

	level_data.load_in(level_code)

	level_name = level_data.name
	#level_background = 

	# loop through all objects in all areas to find the number of shines and star coins
	for area in level_data.areas:
		for object in area.objects:
			match(object.type_id):
				ID_SHINE:
					shine_count += 1
				ID_STAR_COIN:
					star_coin_count += 1

	# initialize time scores for each shine
	for _shine_number in range(shine_count):
		time_scores.append(INT_MAX)

func set_level_data(new_value : LevelData):
	level_data_value = new_value

func get_level_data() -> LevelData:
	if level_data_value == null:
		level_data_value = LevelData.new()
		level_data_value.load_in(level_code)
	return level_data_value


# level_info is a reference, so we can just edit it directly
static func reset_save_data(level_info) -> void:
	level_info.collected_shines = 0
	level_info.collected_star_coins = 0
	level_info.coin_score = 0
	for shine_number in range(level_info.shine_count):
		level_info.time_scores[shine_number] = INT_MAX

func get_saveable_dictionary() -> Dictionary:
	var save_dictionary : Dictionary = \
	{
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

func load_from_dictionary(save_dictionary : Dictionary):
	level_code = save_dictionary["level_code"]
	level_name = save_dictionary["level_name"]
	level_background = save_dictionary["level_background"]
	shine_count = save_dictionary["shine_count"] 
	star_coin_count = save_dictionary["star_coin_count"]

	collected_shines = save_dictionary["collected_shines"]
	collected_star_coins = save_dictionary["collected_star_coins"]
	coin_score = save_dictionary["coin_score"]
	time_scores = save_dictionary["time_scores"]
