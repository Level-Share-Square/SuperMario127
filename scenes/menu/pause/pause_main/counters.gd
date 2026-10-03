extends Control


onready var shine_counter = $CountersLabels/HBoxContainer/ShineCounter
onready var star_coin_counter = $CountersLabels/HBoxContainer/StarCoinCounter


func screen_opened():
	update_counters()


func update_counters():
	if not CurrentLevelData.is_playing_hub_level():
		update_shine_counter()
		update_star_coin_counter()
	else:
		var total_dict: Dictionary = CurrentLevelData.get_meta_collectibles()
		
		var collected_shines: int = total_dict.get("collected_shines", 0)
		var total_shines: int = total_dict.get("total_shines", 0)
		shine_counter.text = "%s/%s" % [collected_shines, total_shines]
		
		var collected_star_coins: int = total_dict.get("collected_star_coins", 0)
		var total_star_coins: int = total_dict.get("total_star_coins", 0)
		star_coin_counter.text = "%s/%s" % [collected_star_coins, total_star_coins]


func update_shine_counter():
	var collectible_data = CurrentLevelData.level_metadata.collectible_data
	var save_data = CurrentLevelData.save_data

	shine_counter.text = "%s/%s" % [save_data.get_completed_mission_count(), collectible_data.used_mission_data.size()]


func update_star_coin_counter():
	var collectible_data = CurrentLevelData.level_metadata.collectible_data
	var save_data = CurrentLevelData.save_data

	var collected_star_coin_count = collectible_data.star_coin_data.size()
	star_coin_counter.text = "%s/%s" % [save_data.get_collected_star_coin_count(), collectible_data.star_coin_data.size()]
