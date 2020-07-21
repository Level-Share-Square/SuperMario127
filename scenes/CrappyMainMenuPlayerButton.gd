extends Button



func _on_button_pressed():
	if level_code_util.is_valid(OS.clipboard):
		var level_data = LevelData.new()
		level_data.load_in(OS.clipboard)
		CurrentLevelData.level_data = level_data
		
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/player/player.tscn")
