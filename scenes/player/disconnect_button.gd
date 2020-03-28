extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

export var pause_screen : NodePath
onready var pause_screen_node = get_node(pause_screen)

var last_hovered

func _pressed():
	click_sound.play()
	Networking.disconnect_from_peers()
	pause_screen_node.toggle_pause()
	
func _process(delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
	if Networking.connected_type == "None":
		disabled = true
	else:
		disabled = false
