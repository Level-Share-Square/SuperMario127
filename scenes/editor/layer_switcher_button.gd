extends TextureButton

export var editor_node_path : NodePath
onready var editor_node = get_node(editor_node_path)

onready var label = $Label
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false

const layerNames = ["BG", "G", "FG"]

func _process(_delta):
	if pressed:
		label.rect_position.y = 43
	else:
		label.rect_position.y = 40
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
	label.text = layerNames[editor_node.layer]

func _pressed():
	click_sound.play()
	editor_node.switch_layers()
