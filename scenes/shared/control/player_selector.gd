extends Button

class_name PlayerSelector

onready var manager = get_parent()

var player_id : int

func _pressed():
	if manager.selectedButton == self:
		return
		
	manager.select(self)
	manager.update_control_bindings()
	
