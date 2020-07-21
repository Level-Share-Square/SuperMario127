extends Node2D

onready var parallax_node = $Parallax
onready var background_node = $Background/Sprite

var ready = false

func _ready():
	ready = true

func load_in(_level_data : LevelData, level_area : LevelArea):
	update_background(level_area)

func update_background(area):
	if !ready:
		yield(self,"ready")
	#warning-ignore:unused_variable
	var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	var background_resource = CurrentLevelData.background_cache[area.settings.sky]
	
	#warning-ignore:unused_variable
	var foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")
	var foreground_resource = CurrentLevelData.foreground_cache[area.settings.background]
	
	background_node.texture = background_resource.texture
	
	for child in parallax_node.get_children():
		child.queue_free()
	for layer in foreground_resource.layers:
		var parallax_layer = ParallaxLayer.new()
		parallax_layer.motion_scale = layer.scale
		parallax_layer.motion_offset = layer.offset
		parallax_layer.motion_mirroring = Vector2(layer.mirroring.x * 2, layer.mirroring.y)
		
		var sprite_instance = TextureRect.new()
		sprite_instance.texture = layer.texture
		sprite_instance.rect_size.x = layer.mirroring.x * 2
		sprite_instance.set_stretch_mode(sprite_instance.STRETCH_TILE)
		sprite_instance.modulate = background_resource.parallax_modulate
		sprite_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		parallax_layer.add_child(sprite_instance)
		parallax_node.add_child(parallax_layer)
		parallax_node.scroll_base_offset.y = (area.settings.bounds.end.y * 32) - 640
