extends Control

class_name Screen

# screen_change signal should be emitted with the args current_screen, new_screeen, transition_id (defaults to 0)
# warning-ignore: unused_signal
signal screen_change

func _open_screen() -> void:
	pass 

func _close_screen() -> void:
	pass
