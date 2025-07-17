class_name ToolManager
extends Control


var mouse_position: Vector2 = get_global_mouse_position()

onready var current_tool: EditorTool = $TilePaint

signal tool_changed()


func _unhandled_input(event: InputEvent) -> void:
	mouse_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
		current_tool._click(event, mouse_position)

	if Input.is_action_just_released("place") or Input.is_action_just_released("erase"):
		current_tool._click_released(event, mouse_position)
	
	if event is InputEventMouseMotion:
		current_tool._mouse_movement(event, mouse_position)


func _physics_process(delta: float):
	if owner.editor_camera.is_moving():
		print("camera moving")
		var event := InputEventMouseMotion.new()
		_unhandled_input(event)


func change_tool(tool_name: String) -> void:
	current_tool = get_node(tool_name)
	print(current_tool)
	emit_signal("tool_changed")


func item_changed(placeable_item: PlaceableItem):
	match current_tool.tool_type:
		EditorTool.Type.TileTool:
			if placeable_item is PlaceableObject:
				change_tool(current_tool.inverse_tool_name)
		EditorTool.Type.ObjectTool:
			if placeable_item is PlaceableTile:
				change_tool(current_tool.inverse_tool_name)
