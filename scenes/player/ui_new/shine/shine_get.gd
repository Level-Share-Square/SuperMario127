extends Control


onready var animation_player = $AnimationPlayer

onready var shine_name = $VBoxContainer/HBoxContainer2/ShineName
onready var shine_name_backing = $VBoxContainer/HBoxContainer2/ShineName/ShineNameBacking


func appear(mission_name: String):
	shine_name.text = mission_name
	shine_name_backing.text = shine_name.text
	
	animation_player.play_backwards("transition")


func disappear():
	animation_player.play("transition")
