class_name LevelParallaxLayer
extends LevelLayer


onready var parallax_scroll: ParallaxScroll = $"%ParallaxScroll"

const AUTOSET_DARKEN_GROWTH = 0.0015

func load_in(layer_data: LayerData):
	parallax_scroll.set_parallax_distance(layer_data.layer_metadata.parallax_distance)
	parallax_scroll.set_lock_axis(layer_data.layer_metadata.lock_axis)
	
	.load_in(layer_data)


func set_parallax_distance(s_parallax_distance: float) -> void:
	parallax_scroll.set_parallax_distance(s_parallax_distance)
	_update_modulate()


func set_screen_offset(s_screen_offset: Vector2) -> void:
	parallax_scroll.set_screen_offset(s_screen_offset)


func set_lock_axis(s_lock_axis: int) -> void:
	parallax_scroll.set_lock_axis(s_lock_axis)


func _modulate_autoset() -> Color:
	var shared = get_tree().current_scene.get_shared_node()
	var is_beyond_frontmost: bool = false
	
	for i in range(shared.layers.size() -1, -1, -1):
		var layer = shared.get_layer(shared.layers[i])
		if layer is LevelGroundLayer:
			break
			
		if layer == self:
			is_beyond_frontmost = true
			break
	
	if parallax_scroll.parallax_distance == 0 and is_beyond_frontmost:
		return Color.white
	
	if parallax_scroll.parallax_distance >= 0:
		return Color.white.darkened(0.5 + 0.45 * (1 - exp(- AUTOSET_DARKEN_GROWTH * parallax_scroll.parallax_distance)))
	else:
		return Color.white
