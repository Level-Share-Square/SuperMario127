extends Node2D

onready var editor: Editor = owner

var action_signal_array: Array = [
	"grid_toggle",
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
	"delete_selection"
]

var modifier_action_signal_array: Array = [
	"copy_selection",
	"cut_selection",
	"paste_clipboard",
	"undo_action",
	"redo_action",
	"save_level"
]

signal grid_toggle
signal hide_hotbar
signal show_options
signal layer_menu
signal item_picker
signal choose_palette
signal pick_focused_item
signal pick_focused_item_released
signal rotate_object
signal scale_object
signal mirror_h
signal mirror_v
signal disable_object
signal last_object
signal last_tile
signal toggle_eraser
signal paint_tool
signal selection_tool
signal fill_tool
signal rect_fill_tool

signal copy_selection
signal cut_selection
signal delete_selection
signal paste_clipboard
signal undo_action
signal redo_action
signal save_level
signal switch_item(key)
signal switch_loadout(key)


func _unhandled_input(event: InputEvent) -> void:
	for action_name in action_signal_array:
		if not Input.is_action_pressed("ctrl_modifier") and event.is_action_pressed(action_name):
			emit_signal(action_name)
			if action_name != "pick_focused_item":
				get_tree().set_input_as_handled()
			#prints(action_name, "emitted")
			break
	
	for action_name in modifier_action_signal_array:
		var ctrl_modifier = Input.is_action_pressed("ctrl_modifier")
		var input_type: int = LastInputDevice.class_type_map.get(event.get_class(), LastInputDevice.InputType.Keyboard)
		if input_type == LastInputDevice.InputType.Controller:
			ctrl_modifier = true
		
		if ctrl_modifier and event.is_action_pressed(action_name):
			emit_signal(action_name)
			get_tree().set_input_as_handled()
			#prints(action_name, "emitted")
			break
			
	for action_name in action_signal_array:
		if not Input.is_action_pressed("ctrl_modifier") and event.is_action_released(action_name):
			if has_signal(action_name + "_released"):
				emit_signal(action_name + "_released")
			break

	if event is InputEventKey and event.is_pressed():
		if event.physical_scancode >= KEY_1 and event.physical_scancode <= KEY_9:
			emit_signal("switch_item", event.physical_scancode - KEY_0 - 1)
		if event.physical_scancode == KEY_0:
			emit_signal("switch_item", 9)
		if event.physical_scancode >= KEY_F1 and event.physical_scancode <= KEY_F4:
			emit_signal("switch_loadout", event.physical_scancode - KEY_F1)
	
	if event.is_action_pressed("8_pixel_lock"):
		editor.pixel_lock = false if editor.invert_pixel_lock else true
		#editor.pixel_lock = !editor.pixel_lock
	
	if event.is_action_released("8_pixel_lock"):
		editor.pixel_lock = true if editor.invert_pixel_lock else false
		#editor.pixel_lock = !editor.pixel_lock
