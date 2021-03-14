extends Control

onready var v_box_container = $ScrollContainer/VBoxContainer
onready var settings_switch = $Settings
onready var new_area = $NewArea

const AREA_PANEL_SCENE = "res://scenes/editor/window/AreaPanel.tscn"

func _ready():
	var _connect = get_parent().connect("window_opened", self, "reload_areas")
	_connect = settings_switch.connect("pressed", self, "switch_to_settings")
	_connect = new_area.connect("pressed", self, "create_area")
	if Singleton.CurrentLevelData.level_data.areas.size() == 6:
		new_area.disabled = true

func reload_areas():
	# child die funny
	for child in v_box_container.get_children():
		child.queue_free()
	
	var index = 0
	for area in Singleton.CurrentLevelData.level_data.areas:
		var area_panel = load(AREA_PANEL_SCENE).instance()
		area_panel.set_background(area.settings.sky, area.settings.background, area.settings.background_palette)
		area_panel.set_id(index)
		v_box_container.add_child(area_panel)
		index += 1
	
	v_box_container.add_child(Control.new()) # because godot :mov:
		
func switch_to_settings():
	get_parent().get_node("LevelSettings").visible = true
	visible = false

func create_area():
	if Singleton.CurrentLevelData.level_data.areas.size() < 6:
		var area = LevelArea.new()
		area.duplicate(Singleton.EditorSavedSettings.default_area)
		Singleton.CurrentLevelData.level_data.areas.append(area)
		reload_areas()

	if Singleton.CurrentLevelData.level_data.areas.size() == 6:
		new_area.disabled = true
