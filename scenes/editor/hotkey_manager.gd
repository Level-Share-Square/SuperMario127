extends Node2D


var action_signal_map: Dictionary = {
	"switch_modes": "playtest"
}

signal playtest_pressed
signal playtest_released


func _unhandled_input(event: InputEvent) -> void:
	for action_name in action_signal_map.keys():
		var signal_name: String = action_signal_map.get(action_name, "")
		if event.is_action_pressed(action_name):
			emit_signal(signal_name + "_pressed")
			break
		if event.is_action_released(action_name):
			emit_signal(signal_name + "_released")
			break
