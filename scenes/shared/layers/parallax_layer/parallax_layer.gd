class_name LevelParallaxLayer
extends LevelLayer


const DISTANCE_SCALE: float = 1000.0


var parallax_distance: float = 0
var scroll_offset: Vector2 = Vector2.ZERO
var screen_offset: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	var scroll_scale: float = parallax_distance / DISTANCE_SCALE
	var canvas_transform: Transform2D = get_canvas_transform()
	var viewport_size: Vector2 = get_viewport_rect().size
	
	set_screen_offset(-canvas_transform.get_origin() + viewport_size / 2.0)
	
#	position = ((-canvas_transform.get_origin() + viewport_size / 2.0) / canvas_transform.get_scale() + scroll_offset) * scroll_scale
#	scale = Vector2(1 - scroll_scale, 1 - scroll_scale)


func load_in(layer_data: LayerData):
	.load_in(layer_data)
	
#	base_offset.x = (CurrentLevelData.area.header.bounds.end.y * 32) - 640
	
	parallax_distance = layer_data.layer_metadata.parallax_distance
	
	tile_map_manager.load_in(layer_data)
	object_manager.load_in(layer_data)


func set_parallax_distance(s_parallax_distance: float) -> void:
	if is_equal_approx(parallax_distance, s_parallax_distance):
		return
	
	parallax_distance = s_parallax_distance
	
#	_update_scroll()
	_update_modulate()


func set_screen_offset(s_screen_offset: Vector2) -> void:
	if screen_offset.is_equal_approx(s_screen_offset):
		return
	
	screen_offset = s_screen_offset
	
	_update_scroll()


func _update_scroll() -> void:
	var canvas_scale: Vector2 = get_canvas_transform().get_scale()
	var canvas_offset: Vector2 = screen_offset / (canvas_scale)
	var scroll_scale: float = parallax_distance / DISTANCE_SCALE * canvas_scale.x * canvas_scale.x
	
	position = (canvas_offset + scroll_offset) * scroll_scale
	scale = Vector2(1 - scroll_scale, 1 - scroll_scale)


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
	
