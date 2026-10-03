extends Node
## Registry of the input-action names that count as editor / player hotkeys.

const EDITOR: Array = [
	"toggle_grid",
	"zoom_in",
	"zoom_out",
	"switch_modes",
	"switch_placement_mode",
	"switch_layers",
	"save_level",
	"toggle_transparency",
	"8_pixel_lock",
	"rotate",
	"undo",
	"redo",
	"flip_object",
	"flip_object_v",
	"toggle_enabled",
	"invis_ui",
]

const PLAYER: Array = [
	"pause",
	"mute",
	"toggle_show",
	"reload",
	"reload_from_start",
	"toggle_crt",
	"fullscreen",
	"volume_up",
	"volume_down",
	"1",
]


func defaults() -> Array:
	return EDITOR + PLAYER


func is_editor_action(action: String) -> bool:
	return EDITOR.has(action)


func is_player_action(action: String) -> bool:
	return PLAYER.has(action)
