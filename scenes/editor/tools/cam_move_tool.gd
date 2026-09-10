extends EditorTool


onready var editor_camera = $"%EditorCamera"
var mouse_input: int = -1


func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	click()


func _click_left_released(_event: InputEvent, _world_pos: Vector2) -> void:
	click_released()


func _click_right(event: InputEvent, world_pos: Vector2) -> void:
	if mouse_input > -1:
		return
	click()


func _click_right_released(event: InputEvent, world_pos: Vector2) -> void:
	click_released()


func click() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	editor_camera.move_override = true
	mouse_input = 0


func click_released() -> void:
	if mouse_input == 0:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		editor_camera.move_override = false
		mouse_input = -1
