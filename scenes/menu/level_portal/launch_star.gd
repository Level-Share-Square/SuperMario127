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
	
	# In case the user went to a different screen while waiting
	if (!is_instance_valid(http_random_level.subscreens.current_screen)):
		button.disabled = false
		animation_player.play("launch", -1,999)
		return
		
	animation_player.play("launch", -1)
	
	if (http_random_level.request_ok):
	
		yield(http_level_page, "request_completed")
	button.disabled = false
