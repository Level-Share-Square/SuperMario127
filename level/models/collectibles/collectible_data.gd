class_name CollectibleData
extends LevelDataResource


# Array of MissionData
var mission_data: Array
# Array of StarCoinData
var star_coin_data: Array

var red_coin_count: int = 0


func _init(s_mission_data: Array = [], s_star_coin_data: Array = [], s_red_coin_count: int = 0) -> void:
	mission_data = s_mission_data
	star_coin_data = s_star_coin_data
	red_coin_count = s_red_coin_count


func get_shine_count() -> int:
	return mission_data.size()


func get_star_coin_count() -> int:
	return star_coin_data.size()
