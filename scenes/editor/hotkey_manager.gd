extends Node2D


var action_signal_map: Dictionary = {
	"grid_toggle": "grid_toggle",
	"hide_hotbar": "hide_hotbar",
	"layer_menu": "layer_menu",
	"item_picker": "item_picker",
	"choose_palette": "choose_palette",
	"pick_focused_item": "pick_focused_item"
}

signal grid_toggle
signal hide_hotbar
signal layer_menu
signal item_picker
signal choose_palette
signal pick_focused_item

func _unhandled_input(event: InputEvent) -> void:
	for action_name in action_signal_map.keys():
		var signal_name: String = action_signal_map.get(action_name, "")
		if event.is_action_pressed(action_name):
			emit_signal(signal_name)
			break
