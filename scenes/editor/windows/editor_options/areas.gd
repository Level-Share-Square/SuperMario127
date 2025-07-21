extends ScrollContainer


onready var v_box_container = $VBoxContainer
onready var new_area = $VBoxContainer/Add


const AREA_PANEL_SCENE = "res://scenes/editor/windows/editor_options/area_panel.tscn"


func _ready():
	var _connect = get_parent().connect("window_opened", self, "reload_areas")
	_connect = new_area.connect("pressed", self, "create_area")
	if Singleton.CurrentLevelData.level_data.areas.size() >= 32:
		new_area.disabled = true
	reload_areas()


func reload_areas():
	# child die funny
	for child in v_box_container.get_children():
		if !"Add" in child.name:
			child.queue_free()
	
	var index = 0
	for area in Singleton.CurrentLevelData.level_data.areas:
		var area_panel = load(AREA_PANEL_SCENE).instance()
		area_panel.set_background(area.settings.sky, area.settings.background, area.settings.background_palette)
		area_panel.set_id(index)
		area_panel.set_name(area.settings.name)
		v_box_container.add_child(area_panel)
		index += 1
	
	v_box_container.add_child(Control.new()) # because godot :mov:
	
	new_area.disabled = (Singleton.CurrentLevelData.level_data.areas.size() >= 32)


func create_area():
	if Singleton.CurrentLevelData.level_data.areas.size() != 32:
		var area = LevelArea.new()
		area.duplicate(Singleton.EditorSavedSettings.default_area)
		Singleton.CurrentLevelData.level_data.areas.append(area)
		reload_areas()

		new_area.disabled = (Singleton.CurrentLevelData.level_data.areas.size() == 32)
