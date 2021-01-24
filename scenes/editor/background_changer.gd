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
onready var sorted_fg_list = preload("res://scenes/shared/background/foregrounds/sort_order.tres")

func update_preview():
	var data = CurrentLevelData.level_data
	var area = data.areas[CurrentLevelData.area]
	var palette = area.settings.background_palette

	var background_mapped_id = background_id_mapper.ids[area.settings.sky]
	var background_resource = load("res://scenes/shared/background/backgrounds/" + background_mapped_id + "/resource.tres")
	
	var foreground_mapped_id = foreground_id_mapper.ids[area.settings.background]
	var foreground_resource = load("res://scenes/shared/background/foregrounds/" + foreground_mapped_id + "/resource.tres")
	
	preview_background.texture = background_resource.texture
	if palette == 0:
		preview_foreground.texture = foreground_resource.preview
	else:
		preview_foreground.texture = foreground_resource.palettes[palette - 1]
	preview_foreground.modulate = background_resource.parallax_modulate
	
	backgrounds_node.update_background(area.settings.sky, area.settings.background, area.settings.bounds, 0, palette)
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

func get_index_in_array(value, array):
	var index = 0
	for found_value in array:
		if value == found_value:
			return index
		index += 1
	return -1
	
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
	
	var foreground_name = foreground_id_mapper.ids[area.settings.background]
	var foreground_index = get_index_in_array(foreground_name, sorted_fg_list.ids)
	
	if !Input.is_action_pressed("change_palette"):
		if foreground_button_left.pressed:
			area.settings.background_palette = 0
			
			foreground_index = wrapi(foreground_index - 1, 0, foreground_id_mapper.ids.size() - 1)
			area.settings.background = get_index_in_array(sorted_fg_list.ids[foreground_index], foreground_id_mapper.ids)
			update_preview()
			click_sound.play()
		elif foreground_button_right.pressed:
			area.settings.background_palette = 0
			
			foreground_index = wrapi(foreground_index + 1, 0, foreground_id_mapper.ids.size() - 1)
			area.settings.background = get_index_in_array(sorted_fg_list.ids[foreground_index], foreground_id_mapper.ids)
			update_preview()
			click_sound.play()
	else:
		var foreground_mapped_id = foreground_id_mapper.ids[area.settings.background]
		var foreground_resource = load("res://scenes/shared/background/foregrounds/" + foreground_mapped_id + "/resource.tres")
		
		
		if foreground_button_left.pressed:
			area.settings.background_palette -= 1
			if area.settings.background_palette < 0:
				area.settings.background_palette = foreground_resource.palettes.size()
			update_preview()
			click_sound.play()
		elif foreground_button_right.pressed:
			area.settings.background_palette += 1
			if area.settings.background_palette >= foreground_resource.palettes.size() + 1:
				area.settings.background_palette = 0
			update_preview()
			click_sound.play()
