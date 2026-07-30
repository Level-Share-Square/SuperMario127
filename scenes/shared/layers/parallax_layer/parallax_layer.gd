class_name LevelParallaxLayer
extends LevelLayer

onready var parallax_scroll: ParallaxScroll = $"%ParallaxScroll"

func load_in(layer_data: LayerData):
	.load_in(layer_data)
	
	parallax_scroll.set_parallax_distance(layer_data.layer_metadata.parallax_distance)
	
	tile_map_manager.load_in(layer_data)
	object_manager.load_in(layer_data)

func set_parallax_distance(s_parallax_distance: float) -> void:
	parallax_scroll.set_parallax_distance(s_parallax_distance)
	_update_modulate()

func set_screen_offset(s_screen_offset: Vector2) -> void:
	parallax_scroll.set_screen_offset(s_screen_offset)

func _modulate_autoset() -> Color:
	if parallax_scroll.parallax_distance > 0:
		return Color.white.darkened(parallax_scroll.parallax_distance)
	else:
		return Color.white

# Tiles
func place_tile(coords, tile_set, tile, palette, update_autotile, modify_data):
	tile_map_manager.place_tile(coords, tile_set, tile, palette, update_autotile, modify_data)


func erase_tile(to_remove: Vector2):
	tile_map_manager.erase_tile(to_remove)


# Objects
func add_object(to_add: ObjectData, modify_data: bool = false):
	return object_manager.place_object(to_add, modify_data)


func place_object(to_place: ObjectData, modify_data: bool = false):
	return object_manager.place_object(to_place, modify_data)


func erase_object(to_remove):
	object_manager.erase_object(to_remove)
	
