extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
onready var controls_options = get_parent().get_parent().get_node("ControlsOptions")

var last_hovered

func _pressed():
	click_sound.play()
	get_parent().visible = false
	controls_options.visible = true
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
