extends Button

func _pressed():
	if CurrentLevelData.level_data.areas.size() <= 1:
		var area = LevelArea.new()
		CurrentLevelData.level_data.areas.append(area)
	CurrentLevelData.area = 1 if CurrentLevelData.area == 0 else 0
	get_tree().reload_current_scene()
