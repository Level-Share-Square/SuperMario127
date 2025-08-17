extends AnimatedSprite

onready var shine_recolorable : AnimatedSprite = $ShineRecolorable
onready var animation_player : AnimationPlayer = $AnimationPlayer

const FRAMES_NORMAL: Resource = preload("res://scenes/actors/objects/shine/frames_normal.tres")
const FRAMES_RECOLORABLE: Resource = preload("res://scenes/actors/objects/shine/frames_recolorable.tres")
const FRAMES_COLLECTED: Resource = preload("res://scenes/actors/objects/shine/frames_collected.tres")

const FRAMES_POCKET: Resource = preload("res://scenes/actors/objects/shine/frames_pocket.tres")
const FRAMES_POCKET_RECOLORABLE: Resource = preload("res://scenes/actors/objects/shine/frames_pocket_recolorable.tres")
const FRAMES_POCKET_COLLECTED: Resource = preload("res://scenes/actors/objects/shine/frames_pocket_collected.tres")

const NORMAL_COLOR := Color(1, 1, 0)
const WHITE_COLOR := Color(1, 1, 1) # because apparently this needs to be const

const SINE_AMOUNT: float = 2.0
const SINE_SPEED: float = 1.5

var selected : bool = false # this is for the animation, and other stuff that might need it
var is_flipped : bool = false # for non-kickout shines

func start_animation() -> void:
	play()
	shine_recolorable.play()

func start_pressed_animation() -> void:
	var animation = "selected" if selected else "disappear"
	animation_player.play(animation)

func make_blue() -> void:
	frames = FRAMES_POCKET_COLLECTED if is_flipped else FRAMES_COLLECTED

func set_color(color : Color) -> void:
	frames = FRAMES_POCKET if is_flipped else FRAMES_NORMAL
	if color != NORMAL_COLOR:
		shine_recolorable.show()
		shine_recolorable.self_modulate = color
		shine_recolorable.frames = FRAMES_POCKET_RECOLORABLE if is_flipped else FRAMES_RECOLORABLE
	else:
		shine_recolorable.hide()

func _process(delta):
	if not is_flipped: return
	offset.y = sin(Time.get_unix_time_from_system() * SINE_SPEED) * SINE_AMOUNT
	shine_recolorable.offset = offset
