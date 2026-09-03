class_name CollectibleData
extends LevelDataResource


# Array of MissionData
var mission_data: Array
# Array of StarCoinData
var star_coin_data: Array
# This is the total_shine_count
var used_mission_data: Dictionary
# Whether mission progression is linear or open
var linear_progression: bool = false
# A list of nozzles that can be saved between playthroughs
var persistent_nozzles: Array = [
	"HoverNozzle",
	"RocketNozzle",
	"TurboNozzle"
]

var red_coin_count: int = 0

# This is the easiest way to bridge the
# gap between the shines' mission tab and
# the level settings mission tab.
signal data_changed(data)


func _init(
	s_mission_data: Array = [], 
	s_star_coin_data: Array = [], 
	s_red_coin_count: int = 0, 
	s_used_mission_data: Dictionary = {}, 
	s_linear_progression: bool = false,
	s_persistent_nozzles: Array = persistent_nozzles
) -> void:
	mission_data = s_mission_data
	star_coin_data = s_star_coin_data
	red_coin_count = s_red_coin_count
	used_mission_data = s_used_mission_data
	linear_progression = s_linear_progression
	persistent_nozzles = s_persistent_nozzles


func get_shine_count() -> int:
	return used_mission_data.size()

func get_menu_shine_count() -> int:
	var count: int = 0
	for mission in used_mission_data:
		if get_mission_by_uuid(mission).mission_show_in_menu: count += 1
		
	return count

func get_star_coin_count() -> int:
	return star_coin_data.size()

func get_mission_by_uuid(uuid: String) -> MissionData:
	for mission in mission_data:
		if mission.mission_uuid == uuid:
			return mission
	return null
	
func add_star_coin(uuid: String = "") -> StarCoinData:
	var data := StarCoinData.new(uuid_util.v4() if not uuid else uuid)

	star_coin_data.append(data)
	return data

func get_star_coin_by_uuid(uuid: String) -> StarCoinData:
	for star_coin in star_coin_data:
		if star_coin.star_coin_uuid == uuid:
			return star_coin
	return null
