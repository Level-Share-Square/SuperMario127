class_name CollectibleData
extends LevelDataResource


# Array of MissionData
var mission_data: Array
# Array of StarCoinData
var star_coin_data: Array


func _init(s_mission_data: Array = [], s_star_coin_data: Array = []) -> void:
	mission_data = s_mission_data
	star_coin_data = s_star_coin_data


func get_shine_count() -> int:
	return mission_data.size()


func get_star_coin_count() -> int:
	return star_coin_data.size()
