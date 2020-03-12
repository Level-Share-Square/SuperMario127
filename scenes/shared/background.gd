extends CanvasLayer

onready var parallax = get_node("../Parallax")
onready var background = get_node("../Background/Sprite")

func load_in(level_data : LevelData, level_area : LevelArea):
	var background_id_mapper = preload("res://scenes/shared/background/backgrounds/ids.tres")
	var background_mapped_id = background_id_mapper.ids[level_area.settings.sky]
	var background_resource = load("res://scenes/shared/background/backgrounds/" + background_mapped_id + "/resource.tres")
	
	var foreground_id_mapper = preload("res://scenes/shared/background/foregrounds/ids.tres")
	var foreground_mapped_id = foreground_id_mapper.ids[level_area.settings.background]
	var foreground_resource = load("res://scenes/shared/background/foregrounds/" + foreground_mapped_id + "/resource.tres")
	
	background.texture = background_resource.texture
	
	for layer in foreground_resource.layers:
		var parallax_instance = ParallaxLayer.new()
		parallax_instance.motion_scale = layer.scale
		parallax_instance.motion_mirroring = layer.mirroring
		
		var sprite_instance = Sprite.new()
		sprite_instance.texture = layer.texture
		sprite_instance.centered = false
		sprite_instance.modulate = background_resource.parallax_modulate
		
		parallax_instance.add_child(sprite_instance)
		parallax.add_child(parallax_instance)
