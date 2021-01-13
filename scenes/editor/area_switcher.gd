extends Button

func on_pressed():
	if CurrentLevelData.level_data.areas.size() <= 1:
		var area = LevelArea.new()
		CurrentLevelData.level_data.areas.append(area)
	CurrentLevelData.area = 1 if CurrentLevelData.area == 0 else 0
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _ready():
	var _area = connect("button_down", self, "on_pressed")
