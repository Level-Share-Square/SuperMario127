extends Node2D

onready var rect = $CanvasLayer/ColorRect

func _ready():
	rect.visible = false

func _input(event):
	if event.is_action_pressed("toggle_crt"):
		rect.visible = !rect.visible
