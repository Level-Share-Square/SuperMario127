class_name ToolManager
extends Control


var mouse_position: Vector2 = get_global_mouse_position()

onready var editor = owner
onready var current_tool: EditorTool = $ObjectPaint

signal tool_changed()

func _unhandled_input(event: InputEvent) -> void:
	mouse_position = get_global_mouse_position()
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("place") :
			current_tool._click_left(event, mouse_position)

		if Input.is_action_just_pressed("erase"):
			current_tool._click_right(event, mouse_position)

		if Input.is_action_just_released("place"):
			current_tool._click_left_released(event, mouse_position)

		if Input.is_action_just_released("erase"):
			current_tool._click_right_released(event, mouse_position)
	elif event is InputEventMouseMotion:
		current_tool._mouse_movement(event, mouse_position)


func _physics_process(delta: float):
	if owner.editor_camera.is_moving():
		var event := InputEventMouseMotion.new()
		current_tool._mouse_movement(event, get_global_mouse_position())


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


func _on_Tools_tool_picked(tool_name):
	match tool_name:
		"Paint":
			if editor.selected_item is PlaceableObject:
				change_tool("ObjectPaint")
			else:
				change_tool("TilePaint")
		"Erase":
			if editor.selected_item is PlaceableObject:
				change_tool("ObjectErase")
			else:
				change_tool("TileErase")
		"Select":
			current_tool = $ObjectSelection #Until we get Tile Selection #Also no clue why it isn't recognizing get_node("ObjectSelection")
		"TileFill":
			change_tool("TileFill")
		"TileRectFill":
			change_tool("TileRectFill")
		"ObjectLock":
			change_tool("ObjectTileLock")
		
