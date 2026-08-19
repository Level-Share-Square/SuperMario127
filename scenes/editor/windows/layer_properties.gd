extends VBoxContainer

onready var layer_name = $"%LayerName"
onready var parallax = $"%Parallax"
onready var is_ground = $"%IsGround"
onready var autoset_tint = $"%AutosetTint"
onready var tint = $"%Tint"
onready var opacity = $"%Opacity"
onready var lock_axis = $"%LockAxis"
onready var enabled_missions = $"%EnabledMissions"
onready var min_shines = $"%MinShines"
onready var max_shines = $"%MaxShines"
onready var switch_layer = $"%SwitchLayer"

onready var editor: Editor = get_tree().current_scene
onready var shared: LevelShared = editor.get_shared_node()
onready var window = owner

var layer_data: LayerData

signal property_changed(key, new_value)

func _ready():
	shared.connect("layer_edited", self, "layer_edited")

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

func layer_edited(uuid: String, key: String, new_value):
	if uuid != shared.layer_index_to_uuid(window.layer_index): return
	emit_signal("property_changed", key, new_value)

func connect_signals(property_editor: PropertyEditor):
	property_editor.connect("property_edited", self, "change_property")
	connect("property_changed", property_editor, "property_changed")

func load_base_properties():
	layer_name.window = window
	layer_name.load_property(editor, get_property_value("layer_name"), [
		"layer_name",
		TYPE_STRING,
		PropertyInfo.new(layer_name.hint_tooltip)
	])
	connect_signals(layer_name)
	
	parallax.window = window
	parallax.load_property(editor, get_property_value("parallax_distance"), [
		"parallax_distance",
		TYPE_REAL,
		PropertyInfo.new(parallax.hint_tooltip, 1, -1000, 1000)
	])
	connect_signals(parallax)
	parallax.visible = not layer_data.layer_metadata.is_ground
	
	autoset_tint.window = window
	autoset_tint.load_property(autoset_tint, get_property_value("autoset_tint"), [
		"autoset_tint",
		TYPE_BOOL,
		PropertyInfo.new(autoset_tint.hint_tooltip)
	])
	connect_signals(autoset_tint)
	
	tint.window = window
	tint.load_property(tint, get_property_value("layer_tint"), [
		"layer_tint",
		TYPE_COLOR,
		PropertyInfo.new(tint.hint_tooltip)
	])
	connect_signals(tint)

	opacity.window = window
	opacity.load_property(opacity, get_property_value("layer_opacity"), [
		"layer_opacity",
		TYPE_COLOR,
		PropertyInfo.new(opacity.hint_tooltip, 0.1, 0, 1)
	])
	connect_signals(opacity)
	
	lock_axis.window = window
	lock_axis.load_property(lock_axis, get_property_value("lock_axis"), [
		"lock_axis",
		["None", "Vertical", "Horizontal", "Both"],
		PropertyInfo.new(lock_axis.hint_tooltip)
	])
	connect_signals(lock_axis)
	
	enabled_missions.window = window
	enabled_missions.load_property(enabled_missions, get_property_value("activated_mission_ids"), [
		"activated_mission_ids",
		[self, "get_mission_args"],
		PropertyInfo.new(enabled_missions.hint_tooltip)
	], "Enabled Missions")
	connect_signals(enabled_missions)
	
	min_shines.window = window
	min_shines.load_property(min_shines, get_property_value("min_shines"), [
		"min_shines",
		TYPE_INT,
		PropertyInfo.new(min_shines.hint_tooltip, 1, -1, CurrentLevelData.level_metadata.collectible_data.mission_data.size())
	])
	connect_signals(min_shines)
	
	max_shines.window = window
	max_shines.load_property(max_shines, get_property_value("max_shines"), [
		"max_shines",
		TYPE_INT,
		PropertyInfo.new(max_shines.hint_tooltip, 1, -1, CurrentLevelData.level_metadata.collectible_data.mission_data.size())
	])
	connect_signals(max_shines)

	if layer_data.layer_metadata.is_origin:
		switch_layer.disabled = true

func switch_layer():
	layer_data = yield(shared.change_layer_type(shared.get_layer_at(layer_data.layer_metadata.order)), "completed")
	window.toggle_window()
	editor.get_node("%ParallaxScroll")._update_parallax()

func get_mission_args() -> Dictionary:
	var args: Dictionary
	for mission_data in CurrentLevelData.level_metadata.collectible_data.mission_data:
		args.get_or_add(mission_data.mission_uuid, mission_data.shine_name)
	return args
