extends TextureButton

onready var hover_sound = $HoverSound
onready var click_sound = $ClickSound
var last_hovered = false

func _ready():
	# Why do I fix everything I touch?
	texture_normal = load(texture_normal.load_path)
	texture_hover = load(texture_hover.load_path)
	texture_pressed = load(texture_pressed.load_path)

func _process(_delta):
	if is_hovered() and !last_hovered:
		hover_sound.play()
	last_hovered = is_hovered()

func _pressed():
	click_sound.play()
