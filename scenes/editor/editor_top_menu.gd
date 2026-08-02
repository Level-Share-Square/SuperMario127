extends HBoxContainer

onready var grid = $"%Grid"
onready var editor_camera = $"%EditorCamera"
onready var settings = $"%Settings"
onready var view_dropdown = $"%ViewDropdown"
onready var editor = owner
onready var shared = editor.get_node("Shared")
onready var layer_adder = $"%LayerAdder"
onready var autosave_window = $"%AutosaveWindow"

func _ready():
	for button in view_dropdown.get_children():
		if !"Separator" in button.name:
			button.connect("button_down", self, "on_button_pressed", [button])
	for button in settings.get_children():
		if !"Separator" in button.name:
			button.connect("button_down", self, "on_button_pressed", [button])
			
func on_button_pressed(button: Button):
	match button.name:
		"Grid":
			grid.toggle_grid(!button.pressed)
		"Layers":
			editor.show_layers = !button.pressed
			for tilemap in shared.tilemaps_node.get_children():
				if editor.show_layers:
					if tilemap.layer != editor.layer:
						tilemap.transparent = true
					else:
						tilemap.transparent = false
				else:
					tilemap.transparent = false
			get_node("%LayersOld").emit_signal("layer_changed", editor.layer)
		"PixelSnap":
			editor.pixel_lock = !button.pressed
		"Layering":
			editor.object_layering = !button.pressed
		"Autosaves":
			autosave_window.toggle_window()
		"Settings":
			editor.screen_manager.screen_change("Options")
		"Layer":
			get_node("%AreaSettingsWindow").toggle_window()
