extends Node2D
 
var character : Character

onready var stamina_display = $CanvasLayer/Stamina
var last_photo_mode := false

func _ready():
	var char_path = get_tree().get_current_scene().character
	character = get_tree().get_current_scene().get_node(char_path)

func _process(_delta):
	if character != null:
		stamina_display.value = character.stamina
	
	if PhotoMode.enabled and !last_photo_mode:
		stamina_display.visible = false
	elif !PhotoMode.enabled and last_photo_mode:
		stamina_display.visible = true
	last_photo_mode = PhotoMode.enabled
