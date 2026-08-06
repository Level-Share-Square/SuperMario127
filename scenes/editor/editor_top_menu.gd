extends HBoxContainer

onready var grid = $"%Grid"
onready var editor_camera = $"%EditorCamera"
onready var settings = $"%Settings"
onready var view_dropdown = $"%ViewDropdown"
onready var editor = owner
onready var shared = editor.get_shared_node()
onready var layer_adder = $"%LayerAdder"
onready var autosave_window = $"%AutosaveWindow"

func _ready():
	for button in view_dropdown.get_children():
		if !"Separator" in button.name:
			button.connect("button_down", self, "on_button_pressed", [button])
			if button.name == "FastTest":
				button.pressed = LocalSettings.load_setting("Editor", "fast_test", false)
	for button in settings.get_children():
		if !"Separator" in button.name:
			button.connect("button_down", self, "on_button_pressed", [button])
			
func on_button_pressed(button: Button):
	match button.name:
		"Grid":
			grid.toggle_grid(!button.pressed)
		"Layers":
			editor.focus_layer = !button.pressed
			shared.focus_layer(editor.focus_layer, editor.layer)
		"PixelSnap":
			editor.pixel_lock = !button.pressed
		"FastTest":
			LocalSettings.change_setting("Editor", "fast_test", !button.pressed)
		"Autosaves":
			autosave_window.toggle_window()
		"Settings":
			editor.screen_manager.screen_change("Options")
