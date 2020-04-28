extends Control

export var backgrounds_node_path : NodePath
onready var backgrounds_node = get_node(backgrounds_node_path)

onready var preview_background = $Preview/BackgroundPreview
onready var preview_foreground = $Preview/ForegroundPreview

onready var background_button_left = $BackgroundButtons/Left
onready var background_button_right = $BackgroundButtons/Right

onready var foreground_button_left = $ForegroundButtons/Left
onready var foreground_button_right = $ForegroundButtons/Right

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

onready var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
onready var foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")

func update_preview():
	var data = CurrentLevelData.level_data
	var area = data.areas[CurrentLevelData.area]

	var background_mapped_id = background_id_mapper.ids[area.settings.sky]
	var background_resource = load("res://scenes/shared/background/backgrounds/" + background_mapped_id + "/resource.tres")
	
	var foreground_mapped_id = foreground_id_mapper.ids[area.settings.background]
	var foreground_resource = load("res://scenes/shared/background/foregrounds/" + foreground_mapped_id + "/resource.tres")
	
	preview_background.texture = background_resource.texture
	preview_foreground.texture = foreground_resource.preview
	preview_foreground.modulate = background_resource.parallax_modulate
	
	backgrounds_node.update_background(area)
	pass

func _ready():
	var _connect = background_button_left.connect("pressed", self, "button_press")
	var _connect2 = background_button_right.connect("pressed", self, "button_press")
	
	var _connect3 = foreground_button_left.connect("pressed", self, "button_press")
	var _connect4 = foreground_button_right.connect("pressed", self, "button_press")
	
	var _connect5 = background_button_left.connect("mouse_entered", self, "button_hovered")
	var _connect6 = background_button_right.connect("mouse_entered", self, "button_hovered")
	
	var _connect7 = foreground_button_left.connect("mouse_entered", self, "button_hovered")
	var _connect8 = foreground_button_right.connect("mouse_entered", self, "button_hovered")
	update_preview()
	
func button_hovered():
	hover_sound.play()
	
func button_press():
	var data = CurrentLevelData.level_data
	var area = data.areas[CurrentLevelData.area]
	if background_button_left.pressed:
		area.settings.sky -= 1
		if area.settings.sky < 0:
			area.settings.sky = background_id_mapper.ids.size() - 1
		update_preview()
		click_sound.play()
	elif background_button_right.pressed:
		area.settings.sky += 1
		if area.settings.sky >= background_id_mapper.ids.size():
			area.settings.sky = 0
		update_preview()
		click_sound.play()
		
	if foreground_button_left.pressed:
		area.settings.background -= 1
		if area.settings.background < 0:
			area.settings.background = foreground_id_mapper.ids.size() - 1
		update_preview()
		click_sound.play()
	elif foreground_button_right.pressed:
		area.settings.background += 1
		if area.settings.background >= foreground_id_mapper.ids.size():
			area.settings.background = 0
		update_preview()
		click_sound.play()
