class_name ToolManager
extends Node


onready var current_tool = $Tools/Pen


signal tool_changed()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("draw"):
		current_tool._click(event, get_global_mouse_position())

	if event.is_action_released("draw"):
		current_tool._click_released(event, event.position + camera.position)
	
	if event is InputEventMouseMotion:
		current_tool._mouse_movement(event, event.position + camera.position)


func change_tool(tool_name: String) -> void:
	cur_tool = get_node(tool_name)
	emit_signal("tool_changed")
