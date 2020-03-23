extends Node2D

export var parallax : NodePath
export var background : NodePath

onready var parallax_node = get_node(parallax)
onready var background_node = get_node(background)

func load_in(level_data : LevelData, level_area : LevelArea):
	update_background(level_area)

func update_background(area):
	var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	var background_mapped_id = background_id_mapper.ids[area.settings.sky]
	var background_resource = load("res://scenes/shared/background/backgrounds/" + background_mapped_id + "/resource.tres")
	
	var foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")
	var foreground_mapped_id = foreground_id_mapper.ids[area.settings.background]
	var foreground_resource = load("res://scenes/shared/background/foregrounds/" + foreground_mapped_id + "/resource.tres")
	
	background_node.texture = background_resource.texture
	
	for child in parallax_node.get_children():
		child.queue_free()
	for layer in foreground_resource.layers:
		var parallax_layer = ParallaxLayer.new()
		parallax_layer.motion_scale = layer.scale
		parallax_layer.motion_offset = layer.offset
		parallax_layer.motion_mirroring = layer.mirroring
		
		var sprite_instance = Sprite.new()
		sprite_instance.texture = layer.texture
		sprite_instance.centered = false
		sprite_instance.modulate = background_resource.parallax_modulate
		
		parallax_layer.add_child(sprite_instance)
		parallax_node.add_child(parallax_layer)
		parallax_node.scroll_base_offset.y = (area.settings.size.y * 32) - 640
