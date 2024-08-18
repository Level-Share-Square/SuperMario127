extends CanvasLayer

## ...what is this script
## how do you make something so simple so weird

func _ready():
	if Singleton.PhotoMode.enabled:
		# like why is this being run twice???
		update_photo_mode(false)
		update_photo_mode(false)

func _input(event):
	var player = get_tree().get_current_scene()
	var character_node = player.get_node(player.character)
	var character2_node 
	if Singleton.PlayerSettings.number_of_players != 1:
		character2_node = player.get_node(player.character2)
	# extremely long if statement jumpscare
	if !Singleton.SceneTransitions.transitioning and (!Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switching_disabled or Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible) and event.is_action_pressed("toggle_ui") and !(get_tree().paused and !Singleton.PhotoMode.enabled):
		if !(character_node.dead or (Singleton.PlayerSettings.number_of_players != 1 and character2_node.dead)):
			Singleton.PhotoMode.enabled = !Singleton.PhotoMode.enabled
			update_photo_mode(false)
		
	
func update_photo_mode(do_pause = true):
	var is_photo_mode = Singleton.PhotoMode.enabled
	offset.y = 1000000 if is_photo_mode else 0 # hax
	#get_tree().paused = is_photo_mode and do_pause
