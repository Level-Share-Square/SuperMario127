extends RichTextLabel

onready var initial_text: String = bbcode_text
var hotkeys: PoolStringArray = [
	"zoom_in",
	"zoom_out",
	"switch_modes",
	"grid_toggle",
	"8_pixel_lock",
	"hide_hotbar",
	"show_options",
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
	"toggle_eraser",
	"paint_tool",
	"selection_tool",
	"fill_tool",
	"rect_fill_tool",
	"copy_selection",
	"cut_selection",
	"paste_clipboard",
	"undo_action",
	"redo_action",
	"save_level"
]

func window_opened():
	bbcode_text = initial_text
	for hotkey in hotkeys:
		bbcode_text = bbcode_text.replace(":%s:" % hotkey, text_replace_util.input_to_text(hotkey, 0, "Editor"))
