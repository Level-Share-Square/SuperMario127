extends ScrollContainer


onready var v_box_container = $VBoxContainer
onready var new_area = $VBoxContainer/HBoxContainer/Add
onready var editor = get_tree().current_scene

onready var drag_area = editor.get_node("%DragArea")

const AREA_PANEL_SCENE = "res://scenes/editor/windows/editor_options/area_panel.tscn"

var is_dragging: bool

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


func _process(_delta: float) -> void:
	if not is_dragging: return
	drag_area.position = get_global_mouse_position()


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


func move_area(areaID: int, delta: int):
	# A positive delta means to move the area down.
	# A negative delta moves it up. (This aligns with the data better)
	var destID = areaID + delta
	var maxID = CurrentLevelData.area_headers.size() - 1
	if destID > maxID or destID < 0:
		return

	# Shift area headers
	var area_data = CurrentLevelData.area_headers.pop_at(areaID)
	CurrentLevelData.area_headers.insert(destID, area_data)

	# This silly thing gives us an id transformation array.
	var idMap = range(0, maxID + 1)
	var tmp = idMap.pop_at(areaID)
	idMap.insert(destID, tmp)
	
	# Properly re-assign the current area_id.
	CurrentLevelData.area_id = idMap.find(CurrentLevelData.area_id)
	reload_areas()
	
	# Shift area cache
	var cacheCopy = CurrentLevelData.loaded_areas
	CurrentLevelData.loaded_areas.clear()
	for origID in range(0, maxID + 1):
		var newID = idMap[origID]
		if cacheCopy.has(origID):
			CurrentLevelData.loaded_areas[newID] = cacheCopy[origID]


func create_area():
	if CurrentLevelData.area_headers.size() != 32:
		var area_code = load(CurrentLevelData.DEFAULT_AREA_PATH).contents
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
