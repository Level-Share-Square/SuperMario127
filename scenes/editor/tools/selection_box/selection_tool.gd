class_name SelectionTool
extends Control

onready var editor = get_tree().get_current_scene()
onready var selection_box = get_owner().get_node("SelectionBox")
var is_active: bool = false

func clicked():
	pass

func commit_to_action():
	pass

func update():
	pass
