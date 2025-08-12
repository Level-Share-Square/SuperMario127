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
	Singleton.CurrentLevelData.level_data.areas[id].name = new_name

func set_id(new_id):
	var id_text = get_node("ID")
	id = new_id
#	name_line.text = "ID: " + str(id)

func swap(areaA : LevelArea, areaB : LevelArea, areasArray : Array) -> Array:
  var area1 = areasArray.find(areaA)
  var area2 = areasArray.find(areaB)
  var temp = areasArray[area1]
  areasArray[area1] = areasArray[area2]
  areasArray[area2] = temp
  return areasArray

func _ready():
	for area in Singleton.CurrentLevelData.level_data.areas:
		area_names.append(area.name)
	area_name.connect("text_changed", self, "area_renamed")
	var _connect = switch_to_button.connect("pressed", self, "switch_to_area")
	_connect = delete_button.connect("pressed", self, "delete_area")
	_connect = duplicate_button.connect("pressed", self, "duplicate_area")
	if id == Singleton.CurrentLevelData.area:
		switch_to_button.disabled = true
		delete_button.disabled = true

func switch_to_area():
	if id != Singleton.CurrentLevelData.area:
		Singleton.CurrentLevelData.area = id
		Singleton.SceneTransitions.reload_scene()


func delete_area():
	if id != Singleton.CurrentLevelData.area:
		Singleton.CurrentLevelData.level_data.areas.remove(id)
		if Singleton.CurrentLevelData.area > id:
			Singleton.CurrentLevelData.area -= 1
		get_parent().get_parent().reload_areas()


func area_renamed(new_text: String):
	if new_text in area_names:
		new_text.erase(new_text.length() - 1, 1)
		area_name.text = new_text
	Singleton.CurrentLevelData.level_data.areas[id].name = new_text


func duplicate_area():
	if Singleton.CurrentLevelData.level_data.areas.size() != 32:
		var area = Singleton.CurrentLevelData.level_data.areas[id].duplicate(true)
		Singleton.CurrentLevelData.level_data.areas.append(area)
		get_parent().get_parent().reload_areas()


func move_area_down():
	if id < Singleton.CurrentLevelData.level_data.areas.size() - 1 && Singleton.CurrentLevelData.level_data.areas.size() > 1:
		var area = Singleton.CurrentLevelData.level_data.areas.pop_at(id)
		Singleton.CurrentLevelData.level_data.areas.insert(id + 1, area)
		
		# Properly re-assign the current area.
		if Singleton.CurrentLevelData.area == id:
			# If the area we're moving is the current area.
			Singleton.CurrentLevelData.area += 1
			
		elif abs(Singleton.CurrentLevelData.area - id) == 1:
			# If the area we're moving is next to the current area.
			Singleton .CurrentLevelData.area -= 1
			
		# Don't re-assign the current area if it isn't next to the area we're moving.
		get_parent().get_parent().reload_areas()


func move_area_up():
	if id > 0 && Singleton.CurrentLevelData.level_data.areas.size() > 1:
		var area = Singleton.CurrentLevelData.level_data.areas.pop_at(id)
		Singleton.CurrentLevelData.level_data.areas.insert(id - 1, area)
		
		if Singleton.CurrentLevelData.area == id:
			
			Singleton.CurrentLevelData.area -= 1
			
		elif abs(Singleton.CurrentLevelData.area - id) == 1:
			
			Singleton.CurrentLevelData.area += 1
			
		get_parent().get_parent().reload_areas()


func copy_area():
	OS.set_clipboard(Singleton.CurrentLevelData.level_data.get_encoded_area_data(Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area]))
