extends PanelContainer

export(NodePath) var editor_path
onready var editor = get_node(editor_path)

onready var tile_lock: Button = $"%ObjectLock"
onready var rectangle_fill: Button = $"%TileFill"
onready var tile_rect_fill = $"%TileRectFill"
onready var item_tools: VBoxContainer = $"%ItemTools"

signal tool_picked(tool_name)

func _ready():
	for button in item_tools.get_children():
		if button is Button:
			detect_tool_buttons(button)
			button.connect("button_down", self, "on_button_pressed", [button])
			
	
func on_button_pressed(button):
	emit_signal("tool_picked", button.name)
	
func detect_tool_buttons(button: Button):
	yield(get_tree(), "idle_frame")
	if "Object" in editor.tool_manager.current_tool.name:
		tile_lock.show()
		rectangle_fill.hide()
		tile_rect_fill.hide()
	else:
		tile_lock.hide()
		rectangle_fill.show()
		tile_rect_fill.show()


func _on_Tools_tool_changed():
	for button in item_tools.get_children():
		if button is Button:
			detect_tool_buttons(button)
			if button.name in editor.tool_manager.current_tool.name:
				button.pressed = true
			else:
				button.pressed = false
				
