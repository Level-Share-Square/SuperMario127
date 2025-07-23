extends HBoxContainer

onready var grid = $"%Grid"
onready var editor_camera = $"%EditorCamera"
onready var settings = $"%Settings"
onready var view_dropdown = $"%ViewDropdown"
onready var editor = owner

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
			pass
		"PixelSnap":
			editor.pixel_lock = !button.pressed
		"ResetZoom":
			editor_camera.set_zoom_level(1.0)
		"Autosaves":
			pass
		"Settings":
			pass
		"Save":
			pass
		"Quit":
			editor.quit_to_menu() #Add unsaved changes check later
