extends VBoxContainer

onready var editor = get_tree().current_scene

onready var gravity = $"%Gravity"
onready var mins = $"%Mins"
onready var sec = $"%Sec"
onready var tile_with_edges = $"%TileWithEdges"
onready var show_name = $"%ShowName"
onready var show_song = $"%ShowSong"
onready var min_time = $"%MinTime"
onready var area_name = $"%Name"


func _ready():
	gravity.connect("value_changed", self, "gravity_changed")
	mins.connect("value_changed", self, "time_changed")
	sec.connect("value_changed", self, "time_changed")
	
	yield(editor, "ready")
	editor.action_manager.connect("action", self, "load_settings")
	editor.action_manager.connect("undo", self, "load_settings")
	editor.action_manager.connect("redo", self, "load_settings")
	load_settings()
	
func load_settings():
	var area = CurrentLevelData.current_area
	
	gravity.set_value_no_signal(area.header.gravity)
	mins.set_value_no_signal(int(area.header.timer/60))
	sec.set_value_no_signal(fmod(area.header.timer, 60.0))
	
	gravity.get_line_edit().text = str(gravity.value)
	mins.get_line_edit().text = str(mins.value) + " m"
	sec.get_line_edit().text = str(sec.value) + " s"
	
	tile_with_edges.load_property(editor, get_property_value("tile_with_edges"), [
		"tile_with_edges",
		TYPE_BOOL,
		PropertyInfo.new(tile_with_edges.hint_tooltip)
	])
	connect_signals(tile_with_edges)
	show_name.load_property(editor, get_property_value("show_name"), [
		"show_name",
		TYPE_BOOL,
		PropertyInfo.new(show_name.hint_tooltip)
	])
	connect_signals(show_name)
	show_song.load_property(editor, get_property_value("show_song"), [
		"show_song",
		TYPE_BOOL,
		PropertyInfo.new(show_song.hint_tooltip)
	])
	connect_signals(show_song)
	min_time.load_property(editor, get_property_value("minimum_timer"), [
		"minimum_timer",
		TYPE_REAL,
		PropertyInfo.new(min_time.hint_tooltip, 1, -1, INF)
	])
	connect_signals(min_time)
	area_name.load_property(editor, get_property_value("name"), [
		"name",
		TYPE_STRING,
		PropertyInfo.new(min_time.hint_tooltip)
	])
	connect_signals(area_name)
	

func gravity_changed(new_value) -> void:
	var action := ChangeAreaAction.new()
	action.property = "gravity"
	action.id = CurrentLevelData.area_id
	action.new_value = new_value
	action.shared = editor.get_shared_node()
	editor.action_manager.commit_action([action])

func time_changed(new_value) -> void:
	var action := ChangeAreaAction.new()
	action.property = "timer"
	action.id = CurrentLevelData.area_id
	action.new_value = mins.value*60 + sec.value
	action.shared = editor.get_shared_node()
	editor.action_manager.commit_action([action])


func change_property(property: String, new_value, check_matches, save_to_data):
	var action := ChangeAreaAction.new()
	action.property = property
	action.id = CurrentLevelData.area_id
	action.new_value = new_value
	action.shared = editor.get_shared_node()
	editor.action_manager.commit_action([action])

func get_property_value(property_id: String):
	return CurrentLevelData.current_area.header[property_id]


func connect_signals(property_editor: PropertyEditor):
	property_editor.connect("property_edited", self, "change_property")
