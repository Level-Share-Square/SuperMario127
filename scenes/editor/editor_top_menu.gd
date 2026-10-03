extends HBoxContainer

onready var grid = $"%Grid"
onready var editor_camera = $"%EditorCamera"
onready var settings = $"%Settings"
onready var view_dropdown = $"%ViewDropdown"
onready var editor = owner
onready var shared = editor.get_shared_node()
onready var layer_adder = $"%LayerAdder"
onready var autosave_window = $"%AutosaveWindow"
onready var snap_value = $"%SnapValue"
onready var pixel_snap = $"%PixelSnap"
onready var target_tag_editor: PropertyEditor = $"%TargetTag"

func _ready():
	for button in view_dropdown.get_children():
		if !"Separator" in button.name:
			button.connect("pressed", self, "on_button_pressed", [button])
			if button.name == "FastTest":
				button.pressed = LocalSettings.load_setting("Editor", "fast_test", false)
	for button in settings.get_children():
		if !"Separator" in button.name:
			button.connect("pressed", self, "on_button_pressed", [button])
	pixel_snap.connect("pressed", self, "on_button_pressed", [pixel_snap])
	snap_value.value = CurrentLevelData.editor_data.pixel_snap.x
	
	load_properties()
			
func load_properties():
	target_tag_editor.load_property(editor, CurrentLevelData.editor_data.target_tag, [
		"target_tag",
		[CurrentLevelData.level_tags, "get_teleport_args", [CurrentLevelData.level_tags, "teleport_tags"]],
		PropertyInfo.new(target_tag_editor.hint_tooltip)
	], "Spawn Tag")
	connect_signals()
	
func connect_signals():
	if !target_tag_editor.is_connected("property_edited", self, "change_property"):
		target_tag_editor.connect("property_edited", self, "change_property")
		
func change_property(key: String, value, check_matches, save_to_data):
	CurrentLevelData.editor_data.target_tag = value
			
func on_button_pressed(button: Button):
	match button.name:
		"Grid":
			grid.toggle_grid(button.pressed)
		"Layers":
			editor.focus_layer = button.pressed
			shared.focus_layer(editor.focus_layer, editor.layer)
		"PixelSnap":
			editor.invert_pixel_lock = button.pressed
			editor.pixel_lock = Input.is_action_pressed("8_pixel_lock")
			if button.pressed:
				editor.pixel_lock = not editor.pixel_lock
		"FastTest":
			LocalSettings.change_setting("Editor", "fast_test", button.pressed)
		"Autosaves":
			autosave_window.toggle_window()
		"Settings":
			editor.screen_manager.screen_change("Options")


func new_snap_value(value):
	CurrentLevelData.editor_data.pixel_snap = Vector2(round(value), round(value))


func dropdown_opened(window):
	load_properties()
