extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered
var hovered: bool = false

func _pressed():
	click_sound.play()
	focus_mode = 0
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
