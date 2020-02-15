extends Node

func _input(event):
	if event.is_action_pressed("30_fps"):
		Engine.target_fps = 30
	elif event.is_action_pressed("60_fps"):
		Engine.target_fps = 60
