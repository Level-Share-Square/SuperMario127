extends VBoxContainer

onready var layer_name = $"%LayerName"
onready var parallax = $"%Parallax"
onready var is_ground = $"%IsGround"
onready var tint = $"%Tint"
onready var opacity = $"%Opacity"
onready var uuid = $"%UUID"

onready var editor: Editor = get_tree().current_scene
onready var shared: LevelShared = editor.get_shared_node()
onready var window = owner

var layer_data: LayerData

func _ready():
	uuid.connect("pressed", self, "copy_uuid")
	
func copy_uuid():
	OS.set_clipboard(shared.layer_index_to_uuid(window.layer_index))

func change_property(property: String, new_value, check_matches):
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
	
	is_ground.load_property(is_ground, get_property_value("is_ground"), [
		"is_ground",
		TYPE_BOOL,
		PropertyInfo.new(is_ground.hint_tooltip)
	])
	connect_signals(is_ground)
	
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
