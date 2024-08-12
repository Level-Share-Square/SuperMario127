extends Control

export var credits_player_path: NodePath
onready var credits_player: AnimationPlayer = get_node(credits_player_path)

func toggle_speed(button_path: String):
	var button = get_node("../" + button_path)
	
	if credits_player.playback_speed == 1:
		credits_player.playback_speed = 5
		button.text = button.text.replace("5", "1")
	else:
		credits_player.playback_speed = 1
		button.text = button.text.replace("1", "5")
