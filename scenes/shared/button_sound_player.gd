extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered

func _pressed():
	click_sound.play()
	
func _process(delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
	pass
