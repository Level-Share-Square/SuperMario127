class_name LevelParallaxLayer
extends LevelLayer


onready var parallax_scroll: ParallaxScroll = $"%ParallaxScroll"


func load_in(layer_data: LayerData):
	.load_in(layer_data)
	
	parallax_scroll.set_parallax_distance(layer_data.layer_metadata.parallax_distance)


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
