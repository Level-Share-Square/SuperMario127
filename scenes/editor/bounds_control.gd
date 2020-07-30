extends Node2D

onready var camera_node = $"../Camera2D"
onready var shared_node = $"../Shared"
onready var backgrounds_node = $"../Backgrounds"
onready var toggle_button_node = $"../UI/BoundsControlToggle"

onready var left_node = $Left
onready var top_node = $Top
onready var right_node = $Right
onready var bottom_node = $Bottom

onready var click_sound = $ClickSound

func _ready():
	pass # Replace with function body.


func _process(delta):
	camera_node.smoothing_enabled = true #kinda hacky way to make sure smoothing won't stay disabled
	
	visible = toggle_button_node.pressed
	
	if(!visible):
		return
	
	var area = CurrentLevelData.level_data.areas[CurrentLevelData.area]
	var camera_position = camera_node.get_camera_screen_center()
	
	left_node.position = Vector2(area.settings.bounds.position.x*32,clamp(camera_position.y,area.settings.bounds.position.y*32,area.settings.bounds.end.y*32))
	left_node.scale = camera_node.zoom
	top_node.position = Vector2(camera_position.x, area.settings.bounds.position.y*32)
	top_node.scale = camera_node.zoom
	right_node.position = Vector2(area.settings.bounds.end.x*32,clamp(camera_position.y,area.settings.bounds.position.y*32,area.settings.bounds.end.y*32))
	right_node.scale = camera_node.zoom
	bottom_node.position = Vector2(camera_position.x, area.settings.bounds.end.y*32)
	bottom_node.scale = camera_node.zoom
	
#will be called from buttons using bounds_control.call("extend_bounds_"+get_parent().name)
func extend_bounds_Left(amount: int):
	var area = CurrentLevelData.level_data.areas[CurrentLevelData.area]
	click_sound.play()
	
	amount = clamp(amount, 24-area.settings.bounds.size.x, 1500-area.settings.bounds.size.x)
	area.settings.bounds = area.settings.bounds.grow_individual(amount,0,0,0)
	shared_node.update_tilemaps()
	camera_node.smoothing_enabled = false #smoothing would mass up spam clicking the buttons
	camera_node.position.x -= 32 * amount
	camera_node.update_limits(area)
	
func extend_bounds_Top(amount: int):
	var area = CurrentLevelData.level_data.areas[CurrentLevelData.area]
	click_sound.play()
	
	amount = clamp(amount, 14-area.settings.bounds.size.y, 1500-area.settings.bounds.size.y)
	area.settings.bounds = area.settings.bounds.grow_individual(0,amount,0,0)
	shared_node.update_tilemaps()
	camera_node.smoothing_enabled = false #smoothing would mass up spam clicking the buttons
	camera_node.position.y -= 32 * amount
	camera_node.update_limits(area)
	
func extend_bounds_Right(amount: int):
	var area = CurrentLevelData.level_data.areas[CurrentLevelData.area]
	click_sound.play()
	
	amount = clamp(amount, 24-area.settings.bounds.size.x, 1500-area.settings.bounds.size.x)
	area.settings.bounds = area.settings.bounds.grow_individual(0,0,amount,0)
	shared_node.update_tilemaps()
	camera_node.smoothing_enabled = false #smoothing would mass up spam clicking the buttons
	camera_node.position.x += 32 * amount
	camera_node.update_limits(area)
	
func extend_bounds_Bottom(amount: int):
	var area = CurrentLevelData.level_data.areas[CurrentLevelData.area]
	click_sound.play()
	
	amount = clamp(amount, 14-area.settings.bounds.size.y, 1500-area.settings.bounds.size.y)
	area.settings.bounds = area.settings.bounds.grow_individual(0,0,0,amount)
	shared_node.update_tilemaps()
	backgrounds_node.update_background(area)
	camera_node.smoothing_enabled = false #smoothing would mass up spam clicking the buttons
	camera_node.position.y += 32 * amount
	camera_node.update_limits(area)
