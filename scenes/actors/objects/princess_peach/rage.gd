extends Node2D


onready var visibility_notifier = $"%VisibilityNotifier2D"
onready var animation_player = $AnimationPlayer
onready var animation_handler = get_parent()

export var visible_alpha: float


func _ready():
	animation_player.play("pulse")


func _process(delta):
	if not visibility_notifier.is_on_screen(): return
	
	if animation_handler.head_anim == "raging":
		modulate.a = lerp(modulate.a, visible_alpha, delta)
	else:
		modulate.a = lerp(modulate.a, 0, delta * 4)
