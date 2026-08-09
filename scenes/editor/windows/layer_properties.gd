extends VBoxContainer

onready var layer_name = $"%LayerName"
onready var parallax = $"%Parallax"
onready var is_ground = $"%IsGround"
onready var autoset_tint = $"%AutosetTint"
onready var tint = $"%Tint"
onready var opacity = $"%Opacity"
onready var switch_layer = $"%SwitchLayer"

onready var editor: Editor = get_tree().current_scene
onready var shared: LevelShared = editor.get_shared_node()
onready var window = owner

var layer_data: LayerData

func copy_uuid():
	OS.set_clipboard(shared.layer_index_to_uuid(window.layer_index))

func change_property(property: String, new_value, check_matches, save_to_data):
	var action := EditLayerAction.new()
	action.shared = shared
	action.layer_index = window.layer_index
	action.property = property
	action.new_value = new_value
	editor.action_manager.commit_action(action)

func get_property_value(property_id: String):
	return layer_data.layer_metadata[property_id]

func connect_signals(property_editor: PropertyEditor):
	property_editor.connect("property_edited", self, "change_property")

func load_base_properties():
	layer_name.load_property(editor, get_property_value("layer_name"), [
		"layer_name",
		TYPE_STRING,
		PropertyInfo.new(layer_name.hint_tooltip)
	])
	connect_signals(layer_name)
	
	parallax.load_property(editor, get_property_value("parallax_distance"), [
		"parallax_distance",
		TYPE_REAL,
		PropertyInfo.new(parallax.hint_tooltip, 1, -1000, 1000)
	])
	connect_signals(parallax)
	parallax.visible = not layer_data.layer_metadata.is_ground
	
	autoset_tint.load_property(autoset_tint, get_property_value("autoset_tint"), [
		"autoset_tint",
		TYPE_BOOL,
		PropertyInfo.new(autoset_tint.hint_tooltip)
	])
	connect_signals(autoset_tint)
	
	tint.load_property(tint, get_property_value("layer_tint"), [
		"layer_tint",
		TYPE_COLOR,
		PropertyInfo.new(tint.hint_tooltip)
	])
	connect_signals(tint)

	opacity.load_property(opacity, get_property_value("layer_opacity"), [
		"layer_opacity",
		TYPE_COLOR,
		PropertyInfo.new(opacity.hint_tooltip, 0.25, 0, 1)
	])
	connect_signals(opacity)


func switch_layer():
	layer_data = yield(shared.change_layer_type(shared.get_layer_at(layer_data.layer_metadata.order)), "completed")
	window.toggle_window()
	editor.get_node("%ParallaxScroll")._update_parallax()
