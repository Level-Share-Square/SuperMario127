extends Button

export var text_edit_path : NodePath
onready var text_edit_node = get_node(text_edit_path)

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

var last_hovered = false

func _pressed():
	click_sound.play()
	focus_mode = 0
	OS.clipboard = text_edit_node.text

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
