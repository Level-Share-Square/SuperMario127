class_name SelectionTool
extends Control

onready var editor = get_tree().get_current_scene()
onready var selection_box = get_owner()
var is_active: bool = false

func clicked():
	pass

func commit_to_action():
	pass

func update():
	pass

func get_mouse_pos() -> Vector2:
	return editor.parallax_scroll.corrected_mouse_position()
