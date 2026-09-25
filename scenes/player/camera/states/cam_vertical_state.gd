class_name CamVerticalState
extends CamState


var pos: float setget _set_pos,_get_pos
func _set_pos(new_val: float) -> void:
	self.camera.global_position.y = new_val
func _get_pos() -> float:
	return self.camera.global_position.y

var vel: float setget _set_vel,_get_vel
func _set_vel(new_val: float) -> void:
	self.camera.velocity.y = new_val
func _get_vel() -> float:
	return self.camera.velocity.y

var size: float setget ,_get_size
func _get_size() -> float:
	return self.camera.size.y

var zoom: float setget ,_get_zoom
func _get_zoom() -> float:
	return self.camera.zoom.y

var char_pos: float setget ,_get_char_pos
func _get_char_pos() -> float:
	return self.character.global_position.y

var char_vel: float setget ,_get_char_vel
func _get_char_vel() -> float:
	return self.character.velocity.y

var char_speed: float setget ,_get_char_speed
func _get_char_speed() -> float:
	return abs(self.character.velocity.y)

var char_center_dist: float setget ,_get_char_center_dist
func _get_char_center_dist() -> float:
	return self.char_pos - self.pos
