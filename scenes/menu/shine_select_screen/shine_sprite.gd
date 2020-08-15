extends AnimatedSprite

onready var shine_outline : AnimatedSprite = $ShineOutline

const frames_normal : Resource = preload("res://scenes/actors/objects/shine/frames_normal.tres")
const frames_recolorable : Resource = preload("res://scenes/actors/objects/shine/frames_recolorable.tres")
const frames_collected : Resource = preload("res://scenes/actors/objects/shine/frames_collected.tres")

func start_animation() -> void:
	play()
	shine_outline.play()

func stop_animation_when_possible() -> void:
	var _connect = connect("animation_finished", self, "on_animation_finished")

func on_animation_finished() -> void:
	frame = 0
	shine_outline.frame = 0
	stop()
	shine_outline.stop()
	
	disconnect("animation_finished", self, "on_animation_finished")

