extends CanvasLayer

func _input(event):
	var player = get_tree().get_current_scene()
	var character_node = player.get_node(player.character)
	var character2_node 
	if PlayerSettings.number_of_players != 1:
		character2_node = player.get_node(player.character2)
	if !scene_transitions.transitioning and !mode_switcher.get_node("ModeSwitcherButton").switching_disabled or mode_switcher.get_node("ModeSwitcherButton").invisible and event.is_action_pressed("30_fps") and !(get_tree().paused and !PhotoMode.enabled):
		if !(character_node.dead or (PlayerSettings.number_of_players != 1 and character2_node.dead)):
			PhotoMode.enabled = !PhotoMode.enabled
			update_photo_mode()
	
func update_photo_mode():
	var is_photo_mode = PhotoMode.enabled
	offset.y = 1000000 if is_photo_mode else 0 # hax
	get_tree().paused = is_photo_mode
