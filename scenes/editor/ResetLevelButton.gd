extends Button

func _on_ResetLevelButton_pressed():
	get_node("/root/CurrentLevelData")._ready()
	# warning-ignore: return_value_discarded
	get_tree().reload_current_scene() 
