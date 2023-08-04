extends Control

onready var switch_to_button = $HBoxContainer/SwitchToButton
onready var delete_button = $HBoxContainer/DeleteButton
onready var duplicate_button = $HBoxContainer/DuplicateButton
# Added for duplicate
onready var new_area = $NewArea

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

func _ready():
	var _connect = switch_to_button.connect("pressed", self, "switch_to_area")
	_connect = delete_button.connect("pressed", self, "delete_area")
	_connect = duplicate_button.connect("pressed", self, "duplicate_area")
	if id == Singleton.CurrentLevelData.area:
		switch_to_button.disabled = true
		delete_button.disabled = true
		
	#Duplicate
	# if Singleton.CurrentLevelData.level_data.areas.size() == 6:
	# 	new_area.disabled = true

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

func duplicate_area():
	if Singleton.CurrentLevelData.level_data.areas.size() < 16:
		var area = LevelArea.new()
		var dup = Singleton.CurrentLevelData.level_data.areas[id]
		area.duplicate(dup)
		Singleton.CurrentLevelData.level_data.areas.append(area)
		get_parent().get_parent().get_parent().reload_areas()
	# new_area.disabled = (Singleton.CurrentLevelData.level_data.areas.size() == 16)
