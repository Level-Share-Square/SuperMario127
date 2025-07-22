extends PanelContainer

export(NodePath) var editor_path
onready var editor = get_node(editor_path)

onready var tile_lock: Button = $"%TileLock"
onready var rectangle_fill: Button = $"%RectangleFill"
onready var item_tools: VBoxContainer = $"%ItemTools"

signal tool_picked(tool_name)

func _ready():
	for button in item_tools.get_children():
		if button is Button:
			button.connect("button_down", self, "on_button_pressed", [button])
	
func on_button_pressed(button):
	emit_signal("tool_picked", button.name)
	


func _on_Tools_tool_changed():
	for button in item_tools.get_children():
		if button.name in editor.tool_manager.current_tool.name:
			button.pressed = true
		elif button is Button:
			button.pressed = false
			
