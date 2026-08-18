class_name ParallaxScroll
extends Node2D

const DISTANCE_SCALE: float = 1000.0
const LOCK_MASKS: Array = [
	Vector2.ZERO,
	Vector2(0, 1),
	Vector2(1, 0),
	Vector2.ONE
]

var parallax_distance: float = 0
var scroll_offset: Vector2 = Vector2.ZERO
var screen_offset: Vector2 = Vector2.ZERO
var lock_axis: int = LayerMetadata.LockAxis.None


func _process(delta: float) -> void:
	var scroll_scale: float = parallax_distance / DISTANCE_SCALE
	var canvas_transform: Transform2D = get_canvas_transform()
	var viewport_size: Vector2 = get_viewport_rect().size
	
	set_screen_offset(-canvas_transform.get_origin() + viewport_size / 2.0)


func set_parallax_distance(s_parallax_distance: float) -> void:
	if is_equal_approx(parallax_distance, s_parallax_distance):
		return
	
	parallax_distance = s_parallax_distance
	
	_update_scroll()


func set_screen_offset(s_screen_offset: Vector2) -> void:
	if screen_offset.is_equal_approx(s_screen_offset):
		return
	
	screen_offset = s_screen_offset
	
	_update_scroll()


func set_lock_axis(s_lock_axis: int) -> void:
	if lock_axis == s_lock_axis:
		return
	
	lock_axis = s_lock_axis
	
	_update_scroll()


func _update_scroll() -> void:
	var canvas_scale: Vector2 = get_canvas_transform().get_scale()
	var canvas_offset: Vector2 = screen_offset / (canvas_scale)
	var scroll_scale: float = parallax_distance / DISTANCE_SCALE * canvas_scale.x
	scroll_scale = min(scroll_scale, 1)
	
	var cur_lock_mask: Vector2 = LOCK_MASKS[lock_axis]
	var scroll_scale_vector: Vector2 = Vector2(scroll_scale if cur_lock_mask.x < 1 else 1, scroll_scale if cur_lock_mask.y < 1 else 1)
	position = (canvas_offset + scroll_offset) * scroll_scale_vector
	scale = Vector2(1 - scroll_scale, 1 - scroll_scale)
