extends Node2D

onready var parallax_node = $Parallax
onready var background_node = $Background/Sprite

var ready = false
var do_auto_scroll = false

func _ready():
	ready = true

func load_in(_level_data : LevelData, level_area : LevelArea):
	update_background(level_area.settings.sky, level_area.settings.background, level_area.settings.bounds, 0, level_area.settings.background_palette)

func update_background_area(area : LevelArea):
	update_background(area.settings.sky, area.settings.background, area.settings.bounds, 0, area.settings.background_palette)

func update_background(sky : int = 1, background : int = 1, bounds : Rect2 = Rect2(0, 0, 0, 0), extra_y_offset : float = 0, background_palette : int = 0):
	if !ready:
		yield(self,"ready")
	#warning-ignore:unused_variable
	var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	var background_resource = Singleton.CurrentLevelData.background_cache[sky]
	
	#warning-ignore:unused_variable
	var foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")
	var foreground_resource = Singleton.CurrentLevelData.foreground_cache[background]
	
	background_node.texture = background_resource.texture
	
	for child in parallax_node.get_children():
		child.queue_free()
	for layer in foreground_resource.layers:
		var parallax_layer = ParallaxLayer.new()
		parallax_layer.motion_scale = layer.scale
		parallax_layer.motion_offset = layer.offset
		parallax_layer.motion_mirroring = Vector2(layer.mirroring.x * 2, layer.mirroring.y)
		
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

func _physics_process(delta):
	if do_auto_scroll:
		parallax_node.scroll_offset.x += delta * 750
	parallax_node.set_ignore_camera_zoom(true)
