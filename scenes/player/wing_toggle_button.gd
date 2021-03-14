extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered

func _ready():
	update_text()
		
func update_text():
	if Singleton.PlayerSettings.legacy_wing_cap:
		text = "On"
	else:
		text = "Off"

func _pressed():
	click_sound.play()
	Singleton.PlayerSettings.legacy_wing_cap = !Singleton.PlayerSettings.legacy_wing_cap
	update_text()
	
func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
