extends PanelContainer


export(NodePath) var editor_path
onready var editor = get_node(editor_path)

onready var tile_lock: Button = $"%ObjectTileLock"
onready var rectangle_fill: Button = $"%TileFill"
onready var tile_rect_fill = $"%TileRectFillTool"
onready var object_trail = $"%ObjectTrailTool"
onready var item_tools: VBoxContainer = $"%ItemTools"
onready var tween = $Tween

const TWEEN_TIME: float = 0.15
const TWEEN_STYLE: int = Tween.TRANS_QUAD
const TWEEN_DIR: int = Tween.EASE_IN_OUT
var is_visible: bool = true

signal tool_picked(tool_name)


func _ready():
	for button in item_tools.get_children():
		if button is Button:
			detect_tool_buttons(button)
			button.connect("pressed", self, "on_button_pressed", [button])


func on_button_pressed(button):
	emit_signal("tool_picked", button.name)


func detect_tool_buttons(button: Button):
	yield(get_tree(), "idle_frame")
	if "Object" in editor.tool_manager.current_tool.name:
		tile_lock.show()
		rectangle_fill.hide()
		tile_rect_fill.hide()
		object_trail.show()
	else:
		tile_lock.hide()
		rectangle_fill.show()
		tile_rect_fill.show()
		object_trail.hide()


func _on_Tools_tool_changed():
	for button in item_tools.get_children():
		if button is Button and button.name != "Erase":
			detect_tool_buttons(button)
			if editor.tool_manager.current_tool.name in button.name or button.name in editor.tool_manager.current_tool.name:
				button.pressed = true
			else:
				button.pressed = false


func toggle_visible(hide: bool = is_visible):
	is_visible = not hide
	
	tween.stop_all()
	tween.interpolate_property(
		self, 
		"anchor_left", 
		anchor_left, 
		0.1 if hide else 0, 
		TWEEN_TIME,
		TWEEN_STYLE,
		TWEEN_DIR
	)
	tween.interpolate_property(
		self, 
		"anchor_right", 
		anchor_right, 
		0.1 if hide else 0, 
		TWEEN_TIME,
		TWEEN_STYLE,
		TWEEN_DIR
	)
	tween.start()
