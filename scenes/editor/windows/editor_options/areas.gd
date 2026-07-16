extends ScrollContainer


onready var v_box_container = $VBoxContainer
onready var new_area = $VBoxContainer/HBoxContainer/Add


const AREA_PANEL_SCENE = "res://scenes/editor/windows/editor_options/area_panel.tscn"


func _ready():
	var _connect = get_parent().connect("window_opened", self, "reload_areas")
	_connect = new_area.connect("pressed", self, "create_area")
	if CurrentLevelData.area_headers.size() >= 32:
		new_area.disabled = true
	reload_areas()


func reload_areas():
	# child die funny
	# that wasn't really funny. 127 is problematic media.
	for child in v_box_container.get_children():
		if !"HBoxContainer" in child.name:
			child.queue_free()
	
	var index = 0
	var default_names: int = 0
	for area in CurrentLevelData.area_headers:
		var area_panel = load(AREA_PANEL_SCENE).instance()
		area_panel.set_background(area.sky, area.background, area.background_palette)
		area_panel.set_id(index)
		if area.name == "My Area":
			default_names = 1
		elif "My Area " + str(default_names) in area.name:
			default_names += 1
		if area.name == "":
			area_panel.set_name("My Area " + str(default_names) if default_names > 0 else "My Area")
			default_names += 1
		else:
			area_panel.set_name(area.name)
		v_box_container.add_child(area_panel)
		index += 1
	
	v_box_container.add_child(Control.new()) # because godot :mov:
	
	new_area.disabled = (CurrentLevelData.area_headers.size() >= 32)


func create_area():
	if CurrentLevelData.level_data.areas.size() != 32:
		var area = AreaDataOld.new()
		area.duplicate(Singleton.EditorSavedSettings.default_area)
		CurrentLevelData.level_data.areas.append(area)
		reload_areas()

	new_area.disabled = (CurrentLevelData.level_data.areas.size() == 32)


func paste_area():
	var area_code: String = OS.get_clipboard()
	if area_code.substr(0, 9) == "AreaData":
		var validity_checker = ValidityChecker.new()
		area_code.erase(0, 10)
		var area = validity_checker.decode_area(area_code)
		for i in area.objects:
			i["properties"].append(i["properties"].pop_front())
		area = conversion_util.get_area_data_from_old_data(area)
		CurrentLevelData.area_headers.append(area.header)
	else: # new validity checker here
		CurrentLevelData.area_headers.append(LevelCodeDeserializer.deserialize_area_code(area_code).header)
	reload_areas()
