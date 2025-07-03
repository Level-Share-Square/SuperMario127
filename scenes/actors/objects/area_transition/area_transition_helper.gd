class_name AreaTransitionHelper
extends Node

var velocity
var state
var facing_direction
var enter_pos
var vertical

func _init(ve, s, f, e : Vector2, v):
	velocity = ve
	state = s
	facing_direction = f
	enter_pos = e
	vertical = v
	
func find_exit_offset(exit_vertical : bool, exit_size : float) -> Vector2:
	if exit_vertical:
		
		return Vector2(32 * sign(velocity.x), -clamp(-enter_pos.y, -exit_size/2, exit_size/2))
	else:
		return Vector2(clamp(enter_pos.x, -exit_size/2, exit_size/2), 45 * sign(velocity.y))

func find_camera_position(exit_vertical : bool, exit_global_position : Vector2, camera_rect : Vector2, exit_size : float):
	if exit_vertical:
		return exit_global_position + Vector2((camera_rect.x + 50) * sign(velocity.x), find_exit_offset(exit_vertical, exit_size).y)
	else:
		return exit_global_position + Vector2(find_exit_offset(exit_vertical, exit_size).x, (camera_rect.y + 50) * sign(velocity.y))
	return exit_global_position + Vector2((camera_rect.x + 16) * sign(velocity.x), (camera_rect.y) + 16 * -sign(velocity.y))  * Vector2(int(!exit_vertical), int(exit_vertical))
