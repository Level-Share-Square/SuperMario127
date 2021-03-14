extends Button

func _on_ResetLevelButton_pressed():
	Singleton.CurrentLevelData.area = 0
	Singleton.CurrentLevelData._ready()
	# warning-ignore: return_value_discarded
	get_tree().reload_current_scene() 
