extends Control

onready var switch_to_button = $HBoxContainer/SwitchToButton
onready var delete_button = $HBoxContainer/DeleteButton
onready var duplicate_button = $HBoxContainer/DuplicateButton
onready var new_area = $NewArea
onready var move_up_button = $MoveArea/MoveUp
onready var move_down_button = $MoveArea/MoveDown

const background_id_mapper = "res://scenes/shared/background/backgrounds/ids.tres"
const foreground_id_mapper = "res://scenes/shared/background/foregrounds/ids.tres"

var id

func set_background(sky, background, palette):
	var background_mapped_id = load(background_id_mapper).ids[sky]
	var background_resource = load("res://scenes/shared/background/backgrounds/" + background_mapped_id + "/resource.tres")
	
	var foreground_mapped_id = load(foreground_id_mapper).ids[background]
	var foreground_resource = load("res://scenes/shared/background/foregrounds/" + foreground_mapped_id + "/resource.tres")
	
	var background_preview = get_node("Preview/BackgroundPreview")
	var foreground_preview = get_node("Preview/ForegroundPreview")
	
	background_preview.texture = background_resource.texture
	if palette == 0:
		foreground_preview.texture = foreground_resource.preview
	else:
		foreground_preview.texture = foreground_resource.palettes[palette - 1]
	foreground_preview.modulate = background_resource.parallax_modulate

func set_id(new_id):
	var id_text = get_node("ID")
	id = new_id
	id_text.text = "ID: " + str(id)

func swap(areaA : LevelArea, areaB : LevelArea, areasArray : Array) -> Array:
  var area1 = areasArray.find(areaA)
  var area2 = areasArray.find(areaB)
  var temp = areasArray[area1]
  areasArray[area1] = areasArray[area2]
  areasArray[area2] = temp
  return areasArray

func _ready():
	var _connect = switch_to_button.connect("pressed", self, "switch_to_area")
	_connect = delete_button.connect("pressed", self, "delete_area")
	_connect = duplicate_button.connect("pressed", self, "duplicate_area")
	_connect = move_down_button.connect("pressed", self, "move_area_down")
	_connect = move_up_button.connect("pressed", self, "move_area_up")
	if id == Singleton.CurrentLevelData.area:
		switch_to_button.disabled = true
		delete_button.disabled = true
	check_moveability()

func switch_to_area():
	if id != Singleton.CurrentLevelData.area:
		Singleton.CurrentLevelData.area = id
		Singleton.SceneTransitions.reload_scene()

func delete_area():
	if id != Singleton.CurrentLevelData.area:
		Singleton.CurrentLevelData.level_data.areas.remove(id)
		if Singleton.CurrentLevelData.area > id:
			Singleton.CurrentLevelData.area -= 1
		get_parent().get_parent().get_parent().reload_areas()
		
func check_moveability():
	var index = id
	if index - 1 == -1:
		move_up_button.disabled = true
	if index + 1 == Singleton.CurrentLevelData.level_data.areas.size():
		move_down_button.disabled = true

func duplicate_area():
	if Singleton.CurrentLevelData.level_data.areas.size() < 32:
		var area = LevelArea.new()
		var dup = Singleton.CurrentLevelData.level_data.areas[id]
		area.duplicate(dup)
		area.settings = Singleton.CurrentLevelData.level_data.areas[id].settings
		Singleton.CurrentLevelData.level_data.areas.append(area)
		get_parent().get_parent().get_parent().reload_areas()
	
func move_area_down():
	if id < Singleton.CurrentLevelData.level_data.areas.size() - 1 && Singleton.CurrentLevelData.level_data.areas.size() > 1:
		var area1 = LevelArea.new()
		area1.duplicate(Singleton.CurrentLevelData.level_data.areas[id])
		area1.settings = Singleton.CurrentLevelData.level_data.areas[id].settings
		Singleton.CurrentLevelData.level_data.areas.remove(id)
		if Singleton.CurrentLevelData.area > id:
			Singleton.CurrentLevelData.area -= 1
		Singleton.CurrentLevelData.level_data.areas.insert(id+1, area1)
		get_parent().get_parent().get_parent().reload_areas()

func move_area_up():
	if id > 0 && Singleton.CurrentLevelData.level_data.areas.size() > 1:
		var area1 = LevelArea.new()
		area1.duplicate(Singleton.CurrentLevelData.level_data.areas[id])
		area1.settings = Singleton.CurrentLevelData.level_data.areas[id].settings
		Singleton.CurrentLevelData.level_data.areas.remove(id)
		if Singleton.CurrentLevelData.area > id:
			Singleton.CurrentLevelData.area -= 1
		Singleton.CurrentLevelData.level_data.areas.insert(id-1, area1)
		get_parent().get_parent().get_parent().reload_areas()
