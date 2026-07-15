class_name LevelParallaxLayer
extends LevelLayer


var parallax_distance: float = 0
var parallax_offset: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
#	var canvas_position: Vector2 = get_canvas_transform().origin
	var canvas_transform: Transform2D = get_canvas_transform()
	position = (-canvas_transform.get_origin() / canvas_transform.get_scale() + (get_viewport_rect().size / 2.0) + parallax_offset) * parallax_distance
	scale = Vector2(1 - parallax_distance, 1 - parallax_distance)


func load_in(layer_data: LayerData):
	.load_in(layer_data)
	
	parallax_distance = layer_data.layer_metadata.parallax_distance
	
	tile_map_manager.load_in(layer_data)
	object_manager.load_in(layer_data)


func _modulate_autoset() -> Color:
	if parallax_distance > 0:
		return Color.white.darkened(parallax_distance)
	else:
		return Color.white


# Tiles
func place_tile(coords, tile_set, tile, palette):
	tile_map_manager.place_tile(coords, tile_set, tile, palette)


func erase_tile(to_remove: Vector2):
	tile_map_manager.erase_tile(to_remove)


# Objects
func add_object(to_add: ObjectData):
	object_manager.create_object(to_add)


func place_object(s_position: Vector2, to_place: ObjectData):
	object_manager.place_object(s_position, to_place)


func erase_object(to_remove):
	object_manager.erase_object(to_remove)
	
