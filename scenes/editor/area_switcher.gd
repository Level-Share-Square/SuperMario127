extends Button

func on_pressed():
	if CurrentLevelData.level_data.areas.size() <= 1:
		var area = LevelArea.new()
		CurrentLevelData.level_data.areas.append(area)
	CurrentLevelData.area = 1 if CurrentLevelData.area == 0 else 0
	get_tree().reload_current_scene()

func _unhandled_key_input(event):
	if event.is_action_pressed("switch_areas"):
		on_pressed()
