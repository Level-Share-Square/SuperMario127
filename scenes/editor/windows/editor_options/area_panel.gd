extends PanelContainer

onready var switch_to_button = $HBoxContainer/SwitchArea
onready var delete_button = $HBoxContainer/VBoxContainer/HBoxContainer/Delete
onready var duplicate_button = $HBoxContainer/VBoxContainer/HBoxContainer/Dupe
onready var area_name = $HBoxContainer/VBoxContainer/LineEdit

onready var x_line = $HBoxContainer/GridContainer2/LineEdit2
onready var y_line = $HBoxContainer/GridContainer2/LineEdit

const background_id_mapper = "res://scenes/shared/background/backgrounds/ids.tres"
const foreground_id_mapper = "res://scenes/shared/background/foregrounds/ids.tres"
onready var background_preview = $"%Background"
onready var foreground_preview = $"%Foreground"

onready var area_settings = get_parent().get_parent()

var id
var area_names: Array = []

func set_background(sky, background, palette):
	var background_mapped_id = load(background_id_mapper).ids[sky]
	var background_resource = load("res://scenes/shared/background/backgrounds/" + background_mapped_id + "/resource.tres")
	
	var foreground_mapped_id = load(foreground_id_mapper).ids[background]
	var foreground_resource = load("res://scenes/shared/background/foregrounds/" + foreground_mapped_id + "/resource.tres")
	
	background_preview = $"%Background"
	foreground_preview = $"%Foreground"
	background_preview.texture = background_resource.texture
	if palette == 0:
		foreground_preview.texture = foreground_resource.preview
	else:
		foreground_preview.texture = foreground_resource.palettes[palette - 1]
	foreground_preview.modulate = background_resource.parallax_modulate

func set_name(new_name: String):
	$HBoxContainer/VBoxContainer/LineEdit.text = new_name
	CurrentLevelData.area_headers[id].name = new_name

func set_id(new_id):
	var id_text = get_node("ID")
	id = new_id
#	name_line.text = "ID: " + str(id)

func swap(areaA : AreaDataOld, areaB : AreaDataOld, areasArray : Array) -> Array:
  var area1 = areasArray.find(areaA)
  var area2 = areasArray.find(areaB)
  var temp = areasArray[area1]
  areasArray[area1] = areasArray[area2]
  areasArray[area2] = temp
  return areasArray

func _ready():
#	for area_id in CurrentLevelData.level_data.areas:
#		area_names.append(area_id.name)
	area_name.connect("text_changed", self, "area_renamed")
	var _connect = switch_to_button.connect("pressed", self, "switch_to_area")
	_connect = delete_button.connect("pressed", self, "delete_area")
	_connect = duplicate_button.connect("pressed", self, "duplicate_area")
	if id == CurrentLevelData.area_id:
		switch_to_button.disabled = true
		delete_button.disabled = true


func switch_to_area():
	if id != CurrentLevelData.area_id:
		var editor = get_tree().current_scene
		editor.get_node("%EditorCamera").save_position()
		CurrentLevelData.switch_to_area(id, false, true)
		CurrentLevelData.editor_data.last_area = id
		
		SceneTransitions.reload_scene()


func delete_area():
	if id != CurrentLevelData.area_id:
		var action := DeleteAreaAction.new()
		action.area_id = id
		area_settings.editor.action_manager.commit_action(action)
		if CurrentLevelData.area_id > id:
			CurrentLevelData.area_id -= 1
		area_settings.reload_areas()


func area_renamed(new_text: String):
	if new_text in area_names:
		new_text.erase(new_text.length() - 1, 1)
		area_name.text = new_text
	CurrentLevelData.area_headers[id].name = new_text


func duplicate_area():
	if CurrentLevelData.area_headers.size() != 32:
		var area_header = CurrentLevelData.area_headers[id].duplicate()
		# the following line is necessary because music
		# can't be an export var (it has 2 different types)
		area_header.music = CurrentLevelData.area_headers[id].music
		print(area_header.music, CurrentLevelData.area_headers[id].music)
		var action := AddAreaAction.new()
		action.area_header = area_header
		area_settings.editor.action_manager.commit_action(action)
		area_settings.reload_areas()


func move_area_down():
	if id < CurrentLevelData.area_headers.size() - 1 && CurrentLevelData.area_headers.size() > 1:
		var area_id = CurrentLevelData.area_headers.pop_at(id)
		CurrentLevelData.area_headers.insert(id + 1, area_id)
		
		# Properly re-assign the current area_id.
		if CurrentLevelData.area_id == id:
			# If the area_id we're moving is the current area_id.
			CurrentLevelData.area_id += 1
			
		elif abs(CurrentLevelData.area_id - id) == 1:
			# If the area_id we're moving is next to the current area_id.
			CurrentLevelData.area_id -= 1
			
		# Don't re-assign the current area_id if it isn't next to the area_id we're moving.
		area_settings.reload_areas()


func move_area_up():
	if id > 0 && CurrentLevelData.area_headers.size() > 1:
		var area_id = CurrentLevelData.area_headers.pop_at(id)
		CurrentLevelData.area_headers.insert(id - 1, area_id)
		
		if CurrentLevelData.area_id == id:
			
			CurrentLevelData.area_id -= 1
			
		elif abs(CurrentLevelData.area_id - id) == 1:
			
			CurrentLevelData.area_id += 1
			
		area_settings.reload_areas()


func copy_area():
	OS.set_clipboard(CurrentLevelData.area_headers[id].area_code)
