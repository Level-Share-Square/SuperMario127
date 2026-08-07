extends Node2D


var action_signal_array: Array = [
	"grid_toggle",
	"hide_hotbar",
	"layer_menu",
	"item_picker",
	"choose_palette",
	"pick_focused_item",
	"rotate_object",
	"scale_object",
	"mirror_h",
	"mirror_v",
	"disable_object",
	"last_object",
	"last_tile",
]

signal grid_toggle
signal hide_hotbar
signal layer_menu
signal item_picker
signal choose_palette
signal pick_focused_item
signal rotate_object
signal scale_object
signal mirror_h
signal mirror_v
signal disable_object
signal last_object
signal last_tile

func _unhandled_input(event: InputEvent) -> void:
	for action_name in action_signal_array:
		if event.is_action_pressed(action_name):
			emit_signal(action_name)
			break
