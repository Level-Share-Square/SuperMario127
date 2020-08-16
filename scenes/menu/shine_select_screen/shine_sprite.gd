extends AnimatedSprite

onready var shine_outline : AnimatedSprite = $ShineOutline

const frames_normal : Resource = preload("res://scenes/actors/objects/shine/frames_normal.tres")
const frames_recolorable : Resource = preload("res://scenes/actors/objects/shine/frames_recolorable.tres")
const frames_collected : Resource = preload("res://scenes/actors/objects/shine/frames_collected.tres")

func start_animation() -> void:
	play()
	shine_outline.play()

func make_blue() -> void:
	frames = frames_collected

