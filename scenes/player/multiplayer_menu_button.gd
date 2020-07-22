extends Button

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound

export var shine_info : NodePath
export var multiplayer_options: NodePath
export var control_options: NodePath

onready var shine_info_node = get_node(shine_info)
onready var multiplayer_options_node = get_node(multiplayer_options)
onready var control_options_node = get_node(control_options)

var last_hovered

func _pressed():
	click_sound.play()
	focus_mode = 0
	if shine_info_node.visible:
		multiplayer_options_node.visible = true
		shine_info_node.visible = false
	else:
		if control_options_node.visible == true:
			control_options_node.visible = false
			control_options_node.reset() # for resetting the Wait... state
			multiplayer_options_node.visible = true
		else:
			SettingsSaver.save(multiplayer_options_node)
			multiplayer_options_node.visible = false
			shine_info_node.visible = true

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()	
	last_hovered = is_hovered()
