class_name CamState
extends Node


var camera: Camera2D
var character: Character setget ,_get_character
func _get_character() -> Character:
	return camera.character_node

export var priority: int = -1
export var axis: String = "y"


var pos: float setget _set_pos,_get_pos
func _set_pos(new_val: float) -> void:
	self.camera.global_position[axis] = new_val
func _get_pos() -> float:
	return self.camera.global_position[axis]

var vel: float setget _set_vel,_get_vel
func _set_vel(new_val: float) -> void:
	self.camera.velocity[axis] = new_val
func _get_vel() -> float:
	return self.camera.velocity[axis]

var size: float setget ,_get_size
func _get_size() -> float:
	return self.camera.size[axis]

var zoom: float setget ,_get_zoom
func _get_zoom() -> float:
	return self.camera.zoom[axis]

var char_pos: float setget ,_get_char_pos
func _get_char_pos() -> float:
	return self.character.global_position[axis]

var char_vel: float setget ,_get_char_vel
func _get_char_vel() -> float:
	return self.character.velocity[axis]

var char_speed: float setget ,_get_char_speed
func _get_char_speed() -> float:
	return abs(self.character.velocity[axis])

var char_center_dist: float setget ,_get_char_center_dist
func _get_char_center_dist() -> float:
	return self.char_pos - self.pos


func _enter_tree():
	camera = get_owner()


func start_check() -> bool:
	return false


func stop_check() -> bool:
	return false


func start() -> void:
	pass


func stop() -> void:
	pass


func update(_delta: float) -> void:
	pass


func reset_vars() -> void:
	pass


func general_update(_delta: float):
	pass
