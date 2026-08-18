extends Control


export var collectible_text: String = "%s key"
export var collectible_text_hidden: String = "%s"

onready var animation_player = $AnimationPlayer
onready var key_name = $VBoxContainer/KeyName
onready var key_name_backing = $VBoxContainer/KeyName/Backing

signal appearing

func appear(key_id: String, collect_text: String, is_visible: bool = true):
	var key_text: String = (collectible_text if is_visible else collectible_text_hidden) % [key_id]
	key_name.text = collect_text.replace("{key}", key_text)
	key_name_backing.text = key_name.text
	
	animation_player.play_backwards("transition")
	emit_signal("appearing")


func disappear():
	animation_player.play("transition")
