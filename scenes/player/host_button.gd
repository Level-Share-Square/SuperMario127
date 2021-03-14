extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered

func _pressed():
	click_sound.play()
	if Singleton.Networking.connected_type == "None":
		Singleton.Networking.start_server()

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
	if Singleton.Networking.connected_type != "None":
		disabled = true
	else:
		disabled = false
