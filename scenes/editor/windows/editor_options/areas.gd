extends ScrollContainer


onready var v_box_container = $VBoxContainer
onready var new_area = $VBoxContainer/HBoxContainer/Add
onready var editor = get_tree().current_scene

const AREA_PANEL_SCENE = "res://scenes/editor/windows/editor_options/area_panel.tscn"


func _ready():
	var _connect = get_parent().connect("window_opened", self, "reload_areas")
	_connect = new_area.connect("pressed", self, "create_area")
	if CurrentLevelData.area_headers.size() >= 32:
		new_area.disabled = true
	
	yield(editor, "ready")
	editor.action_manager.connect("action", self, "action_taken")
	editor.action_manager.connect("undo", self, "action_taken")
	editor.action_manager.connect("redo", self, "action_taken")
	reload_areas()
	

func action_taken():
	var actions: Array = [editor.action_manager.undo_stack.back(), editor.action_manager.redo_stack.back()]
	var found_action: bool = false
	for action in actions:
		if (action is BaseAreaAction or action is ChangeAreaAction):
			found_action = true
	if !found_action: return
	
	reload_areas()

func reload_areas():
	# child die funny
	# that wasn't really funny. 127 is problematic media.
	var actions: Array = [editor.action_manager.undo_stack.back(), editor.action_manager.redo_stack.back()]
	
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
	if CurrentLevelData.area_headers.size() != 32:
		var area_code = level_list_util.load_level_code_file(CurrentLevelData.DEFAULT_AREA_PATH)
		var area = LevelCodeDeserializer.deserialize_area_header_code(area_code)
		
		var action := AddAreaAction.new()
		action.area_header = area
		editor.action_manager.commit_action([action])
		reload_areas()

	new_area.disabled = (CurrentLevelData.area_headers.size() == 32)


func paste_area():
	var area_code: String = OS.get_clipboard()
	area_code = area_code.strip_edges().strip_escapes()
	
	var area_header
	if area_code.substr(0, 9) == "AreaData":
		var validity_checker = ValidityChecker.new()
		area_code.erase(0, 10)
		var area = validity_checker.decode_area(area_code)
		for i in area.objects:
			i["properties"].append(i["properties"].pop_front())
		area_header = conversion_util.get_area_data_from_old_data(area).header
	elif level_code_validator_util.validate_area_code(area_code):
		area_header = LevelCodeDeserializer.deserialize_area_code(area_code).header
	else:
		printerr("Invalid area code: ", area_code)
		
	if area_header:
		var action := AddAreaAction.new()
		action.area_header = area_header
		editor.action_manager.commit_action([action])
		reload_areas()
