extends Node2D

onready var parallax_node = $Parallax
onready var background_node = $Background/Sprite

var ready = false
var do_auto_scroll = false
var auto_scroll_speed := 0.0

func _ready():
	ready = true

func load_in(_level_data : LevelData, level_area : LevelArea):
	update_background(level_area.settings.sky, level_area.settings.background, level_area.settings.bounds, 0, level_area.settings.background_palette)

func update_background_area(area : LevelArea):
	update_background(area.settings.sky, area.settings.background, area.settings.bounds, 0, area.settings.background_palette)

func update_background(sky : int = 1, background : int = 1, bounds : Rect2 = Rect2(0, 0, 0, 0), extra_y_offset : float = 0, background_palette : int = 0, speed_override: float = 0):
	if !ready:
		yield(self,"ready")
		
	#warning-ignore:unused_variable
	var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	var background_resource = Singleton.CurrentLevelData.get_cached_background(sky)
	
	#warning-ignore:unused_variable
	var foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")
	var foreground_resource = Singleton.CurrentLevelData.get_cached_foreground(background)
	
	background_node.texture = background_resource.texture
	
	for child in parallax_node.get_children():
		child.queue_free()
	for layer in foreground_resource.layers:
		var parallax_layer = ParallaxLayer.new()
		parallax_layer.motion_scale = layer.scale
		parallax_layer.motion_offset = layer.offset
		parallax_layer.motion_mirroring = Vector2(layer.mirroring.x * 2, layer.mirroring.y)
		
		# print("\n\nCHANGED Motion Scale:\t", parallax_layer.motion_scale, "\nMotion Offset:\t", parallax_layer.motion_offset, "\nMotion Mirroring:\t", parallax_layer.motion_mirroring)
		
		var sprite_instance = TextureRect.new()
		if background_palette == 0:
			sprite_instance.texture = layer.texture
		else:
			sprite_instance.texture = layer.palettes[background_palette - 1]
			
		sprite_instance.rect_size.x = layer.mirroring.x * 2
		sprite_instance.set_stretch_mode(sprite_instance.STRETCH_TILE)
		if !(sky in foreground_resource.immune_to):
			sprite_instance.modulate = background_resource.parallax_modulate
		sprite_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		parallax_layer.add_child(sprite_instance)
		parallax_node.add_child(parallax_layer)
		parallax_node.scroll_base_offset.y = (bounds.end.y * 32) - 640
		
		parallax_node.offset.y += extra_y_offset
	
	auto_scroll_speed = 0
	parallax_node.scroll_base_scale.x = 1
	
	if foreground_resource.auto_scroll_speed > 0.0:
		do_auto_scroll = true
		parallax_node.scroll_base_scale.x = 0
		auto_scroll_speed = foreground_resource.auto_scroll_speed
	
	if speed_override > 0:
		do_auto_scroll = true
		parallax_node.scroll_base_scale.x = 0
		auto_scroll_speed = speed_override

func _process(delta):
	if do_auto_scroll:
		parallax_node.scroll_base_offset.x += auto_scroll_speed*delta
	parallax_node.set_ignore_camera_zoom(true)
