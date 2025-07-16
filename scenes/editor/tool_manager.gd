class_name ToolManager
extends Control


var mouse_position: Vector2 = get_global_mouse_position()

onready var current_tool: EditorTool = $Pen


signal tool_changed()


func _unhandled_input(event: InputEvent) -> void:
	mouse_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
		current_tool._click(event, mouse_position)

	if Input.is_action_just_released("place") or Input.is_action_just_released("erase"):
		current_tool._click_released(event, mouse_position)
	
	if event is InputEventMouseMotion or _is_camera_moving():
		current_tool._mouse_movement(event, mouse_position)
	
	print(mouse_position)


func _is_camera_moving():
	var direction := Input.get_vector("editor_left", "editor_right", "editor_up", "editor_down")
	
	return direction.length() > 0


func change_tool(tool_name: String) -> void:
	current_tool = get_node(tool_name)
	emit_signal("tool_changed")
