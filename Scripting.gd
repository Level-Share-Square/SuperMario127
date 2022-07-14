extends Control

export var window : NodePath
export var starting_position : Vector2
onready var window_node = get_node(window)
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false

func _process(_delta):
	if Input.is_action_just_pressed("RMB"):
		if window_node.visible:
			window_node.close()
			window_node.rect_position = get_global_mouse_position()
		else:
			window_node.rect_position = get_global_mouse_position()
			window_node.open()
