extends CanvasLayer

onready var button = $Button
onready var animation_player = $Button/AnimationPlayer

func pressed():
	button.disabled = true
	
	animation_player.play("windup", -1)
	yield(animation_player, "animation_finished")
	animation_player.play("launch", -1)
	yield(animation_player, "animation_finished")
	
	button.disabled = false
