extends Node

class_name LevelInfo

const INT_MAX = 9223372036854775807
const ID_SHINE = 2 
const ID_STAR_COIN = -1 #get the correct id later

# this class stores all the info and savedata relating to a level that can be played from the level list 

var level_data : LevelData

# level info
var level_name : String = ""
var level_background : int = 0 
var shine_count : int = 0 
var star_coin_count : int = 0

# save data 
var collected_shines : int = 0
var collected_star_coins : int = 0
var coin_score : int = 0
var time_scores : Array = [] # time_scores should probably be stored as the sum of delta while playing

func _init(passed_level_data) -> void:
	level_data = passed_level_data

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

# level_info is a reference, so we can just edit it directly
static func reset_save_data(level_info) -> void:
	level_info.collected_shines = 0
	level_info.collected_star_coins = 0
	level_info.coin_score = 0
	for shine_number in range(level_info.shine_count):
		level_info.time_scores[shine_number] = INT_MAX
