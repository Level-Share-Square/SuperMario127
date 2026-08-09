class_name ToolManager
extends Control

onready var editor = owner
onready var parallax_scroll = $"%ParallaxScroll"
onready var current_tool: EditorTool = $ObjectPaint
onready var click_sound = $"%ClickSound"

var mouse_position: Vector2
var is_erasing: bool

signal tool_changed
signal eraser_toggled(new_value)

func _ready():
	yield(editor, "ready")
	if editor.selected_item is PlaceableObject:
		change_tool("ObjectPaint")
	else:
		change_tool("TilePaint")
	editor.connect("item_changed", self, "item_changed")

func _unhandled_input(event: InputEvent) -> void:
	mouse_position = parallax_scroll.corrected_mouse_position()
	
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("place"):
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
	
	var item_preview = get_node("%ItemPreview")
	item_preview.position_override = false
	item_preview.visible = !"Selection" in tool_name
	
	for texture in get_node("%ObjectBuffer").get_children():
		texture.queue_free()
	get_node("%TileBuffer").clear()
	
	var item_actions_manager = get_node("%ItemActionsManager")
	item_actions_manager.handle_selection()
	item_actions_manager.clear_selection()
	
	emit_signal("tool_changed")

func item_changed(placeable_item: PlaceableItem):
	match current_tool.tool_type:
		EditorTool.Type.TileTool:
			if placeable_item is PlaceableObject:
				var new_tool: String = current_tool.inverse_tool_name if current_tool.inverse_tool_name else "ObjectPaint"
				change_tool(new_tool)
		EditorTool.Type.ObjectTool:
			if placeable_item is PlaceableTile:
				var new_tool: String = current_tool.inverse_tool_name if current_tool.inverse_tool_name else "TilePaint"
				change_tool(new_tool)

func _on_Tools_tool_picked(tool_name):
	match tool_name:
		"Paint":
			if editor.selected_item is PlaceableObject:
				change_tool("ObjectPaint")
			else:
				change_tool("TilePaint")
		"Erase":
			toggle_eraser()
		"Select":
			if editor.selected_item is PlaceableObject:
				change_tool("%ObjectSelection")
			else:
				change_tool("%TileSelection")
		"TileFill":
			change_tool("TileFill")
		"TileRectFillTool":
			change_tool("%TileRectFill")
		"ObjectTileLock":
			change_tool("ObjectTileLock")
		"ObjectTrailTool":
			change_tool("%ObjectTrail")


func pick_fill_or_lock() -> void:
	click_sound.play()
	if editor.selected_item is PlaceableObject:
		change_tool("ObjectTileLock")
	else:
		change_tool("TileFill")


func pick_rect_or_path() -> void:
	click_sound.play()
	if editor.selected_item is PlaceableObject:
		change_tool("%ObjectTrail")
	else:
		change_tool("%TileRectFill")


func toggle_eraser():
	is_erasing = not is_erasing
	emit_signal("eraser_toggled", is_erasing)
