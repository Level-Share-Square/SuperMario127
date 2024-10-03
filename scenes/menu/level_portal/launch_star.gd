extends Control


onready var http_random_level = $"%HTTPRandomLevel"
onready var http_level_page = $"%HTTPLevelPage"

onready var button = $Button
onready var animation_player = $Button/AnimationPlayer


func pressed():
	button.disabled = true
	
	http_random_level.load_random_level()
	
	animation_player.play("windup", -1)
	
	yield(http_random_level, "request_completed")
	animation_player.play("launch", -1)
	
	yield(http_level_page, "request_completed")
	button.disabled = false
