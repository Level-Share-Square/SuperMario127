extends AnimatedSprite

onready var shine_outline : AnimatedSprite = $ShineOutline
onready var animation_player : AnimationPlayer = $AnimationPlayer

const frames_normal : Resource = preload("res://scenes/actors/objects/shine/frames_normal.tres")
const frames_recolorable : Resource = preload("res://scenes/actors/objects/shine/frames_recolorable.tres")
const frames_collected : Resource = preload("res://scenes/actors/objects/shine/frames_collected.tres")

const NORMAL_COLOR := Color(1, 1, 0)
const WHITE_COLOR := Color(1, 1, 1) # because apparently this needs to be const

var selected : bool = false # this is for the animation, and other stuff that might need it

func start_animation() -> void:
	play()
	shine_outline.play()

func start_pressed_animation() -> void:
	var animation = "selected" if selected else "disappear"
	animation_player.play(animation)

func make_blue() -> void:
	frames = frames_collected

func set_color(color : Color) -> void:
	if color != NORMAL_COLOR:
		self_modulate = color
		frames = frames_recolorable
	else:
		self_modulate = WHITE_COLOR
		frames = frames_normal
