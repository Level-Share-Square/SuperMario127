extends TextureButton

export var editor_node_path : NodePath
onready var editor_node = get_node(editor_node_path)

onready var label = $Label
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered := false

#fontsize, text
const layerNames = [
	[50,"BG1"], 
	[64,"G"], 
	[64,"FG"], 
	[50,"BG0"]
]

func _process(_delta):
	label.rect_position.y = 2 if pressed else -1
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()
	
	label.get("custom_fonts/font").size = layerNames[editor_node.editing_layer][0]
	label.text = layerNames[editor_node.editing_layer][1]

func _pressed():
	click_sound.play()
	editor_node.switch_layers()
