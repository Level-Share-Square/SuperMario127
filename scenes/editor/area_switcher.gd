extends Button

func on_pressed():
	if Singleton.CurrentLevelData.level_data.areas.size() <= 1:
		var area = LevelArea.new()
		Singleton.CurrentLevelData.level_data.areas.append(area)
	Singleton.CurrentLevelData.area = 1 if Singleton.CurrentLevelData.area == 0 else 0
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _ready():
	var _area = connect("button_down", self, "on_pressed")
