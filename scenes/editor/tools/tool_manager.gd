class_name ToolManager
extends Control

onready var editor = owner
onready var parallax_scroll = $"%ParallaxScroll"
onready var current_tool: EditorTool = $ObjectPaint

var mouse_position: Vector2

signal tool_changed()

func _ready():
	yield(editor, "ready")
	if editor.selected_item is PlaceableObject:
		change_tool("ObjectPaint")
	else:
		change_tool("TilePaint")

func _unhandled_input(event: InputEvent) -> void:
	mouse_position = parallax_scroll.corrected_mouse_position()
	
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


func _process(_delta: float):
	if owner.editor_camera.is_moving():
		var event := InputEventMouseMotion.new()
		current_tool._mouse_movement(event, parallax_scroll.corrected_mouse_position())


func change_tool(tool_name: String) -> void:
	current_tool = get_node(tool_name)
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
			if editor.selected_item is PlaceableObject:
				change_tool("%ObjectSelection")
			else:
				change_tool("TileSelection")
		"TileFill":
			change_tool("TileFill")
		"TileRectFill":
			change_tool("TileRectFill")
		"ObjectLock":
			change_tool("ObjectTileLock")
		"ObjectTrail":
			change_tool("ObjectTrail")
		
