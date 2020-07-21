extends Button

func _on_button_pressed():
	# warning-ignore:return_value_discarded	
	get_tree().change_scene("res://scenes/editor/editor.tscn")
