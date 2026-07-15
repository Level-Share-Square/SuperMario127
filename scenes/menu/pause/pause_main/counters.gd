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
	pass
#	var level_info = CurrentLevelData.level_info
#
#	# Only count shine sprites that have show_in_menu on
#	var total_shine_count := 0
#	var collected_shine_count := 0
#
#	for shine_details in level_info.shine_details:
#		total_shine_count += 1
#		if level_info.collected_shines[str(shine_details["id"])]:
#			collected_shine_count += 1
#
#	shine_counter.text = "%s/%s" % [collected_shine_count, total_shine_count]


func update_star_coin_counter():
	pass
#	var level_info = CurrentLevelData.level_info
#
#	var collected_star_coin_count = level_info.collected_star_coins.values().count(true)
#	star_coin_counter.text = "%s/%s" % [collected_star_coin_count, level_info.collected_star_coins.size()]
