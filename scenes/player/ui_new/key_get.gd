extends Control


export var default_text = "You got the %s key!"

onready var animation_player = $AnimationPlayer
onready var key_name = $VBoxContainer/KeyName
onready var key_name_backing = $VBoxContainer/KeyName/Backing


func appear(key_id: String):
	key_name.text = default_text % [key_id]
	key_name_backing.text = key_name.text
	
	animation_player.play_backwards("transition")


func disappear():
	animation_player.play("transition")
