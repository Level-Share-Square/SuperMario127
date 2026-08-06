extends Node

onready var editor = owner
onready var shared = $"%LevelShared"

func rotate_object():
	var hovered_objects: Dictionary = editor.get_hovered_objects()
	if !editor.get_hovered_objects(): return
	
	editor.selected_objects = [hovered_objects.values()[0]]
