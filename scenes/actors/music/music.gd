extends AudioStreamPlayer

export var play_bus: String
export var edit_bus: String

func _process(delta):
	if get_tree().get_current_scene().mode == 0:
		bus = play_bus
	else:
		bus = edit_bus
	
