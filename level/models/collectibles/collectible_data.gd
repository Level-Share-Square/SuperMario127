class_name CollectibleData
extends LevelDataResource


# Array of MissionData
var mission_data: Array
# Array of StarCoinData
var star_coin_data: Array
# This is the total_shine_count
var used_mission_data: Dictionary

var red_coin_count: int = 0


func _init(s_mission_data: Array = [], s_star_coin_data: Array = [], s_red_coin_count: int = 0, s_used_mission_data: Dictionary = {}) -> void:
	mission_data = s_mission_data
	star_coin_data = s_star_coin_data
	red_coin_count = s_red_coin_count
	used_mission_data = s_used_mission_data


func get_shine_count() -> int:
	return mission_data.size()


func get_star_coin_count() -> int:
	return star_coin_data.size()

func get_mission_by_uuid(uuid: String) -> MissionData:
	for mission in mission_data:
		if mission.mission_uuid == uuid:
			return mission
	return null
	
func add_star_coin(uuid: String = "") -> String:
	var data := StarCoinData.new(uuid_util.v4() if not uuid else uuid, "", Color.white)

	star_coin_data.append(data)
	return data.star_coin_uuid
