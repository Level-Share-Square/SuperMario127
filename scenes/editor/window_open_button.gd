extends TextureButton

export var window : NodePath
export var starting_position : Vector2
onready var window_node = $HelpWindow
onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false

func _ready():
	# Why do I fix everything I touch?
	texture_normal = load(texture_normal.load_path)
	texture_hover = load(texture_hover.load_path)
	texture_pressed = load(texture_pressed.load_path)

func _process(_delta):
	last_hovered = is_hovered()

func _pressed():
	if window_node.visible:
		window_node.close()
		window_node.rect_position = starting_position
	else:
		window_node.rect_position = starting_position
		window_node.open()
