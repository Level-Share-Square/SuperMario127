extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
onready var volume_mixer = $"../../VolumeMixer"

var last_hovered

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
#
func _on_VolumeMixer_pressed():
	get_parent().get_parent().vm_open = true
	get_parent().get_parent().page_select.visible = false
	volume_mixer.visible = true
	click_sound.play()
