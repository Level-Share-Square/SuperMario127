extends NinePatchRect

onready var global_vars = get_node("../../GlobalVars")
onready var label = get_node("Label")
export var window_title := "Window"
var drag_position = null

func _ready():
	label.text = window_title

func _on_Window_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print("e")
