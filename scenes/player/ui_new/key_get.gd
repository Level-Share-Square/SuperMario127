extends Control


export var default_text = "You got the %s key!"
export var hidden_text = "You got the %s!"

onready var animation_player = $AnimationPlayer
onready var key_name = $VBoxContainer/KeyName
onready var key_name_backing = $VBoxContainer/KeyName/Backing


func appear(key_id: String, is_visible: bool = true):
	key_name.text = (default_text if is_visible else hidden_text) % [key_id]
	key_name_backing.text = key_name.text
	
	animation_player.play_backwards("transition")


func disappear():
	animation_player.play("transition")
