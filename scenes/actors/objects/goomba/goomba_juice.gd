extends AnimatedSprite


onready var enemy: KinematicBody2D = get_owner()

export var lerp_speed: float = 1.0
export var color_lerp_speed: float = 1.0


func _physics_process(delta):
	if enemy.cur_state == "DieState": return
	
	if not scale.is_equal_approx(Vector2.ONE):
		scale = lerp(scale, Vector2.ONE, delta * lerp_speed)

	if not modulate.is_equal_approx(Color.white):
		modulate = lerp(modulate, Color.white, delta * color_lerp_speed)
