extends Area2D


const DAMAGE: int = 1
const ROTATION_SPEED: float = 8.0

onready var sprite = $Sprite
onready var visibility_notifier = $VisibilityNotifier2D

export var velocity: Vector2
var entered_screen: bool


func _physics_process(delta):
	sprite.rotation_degrees += ROTATION_SPEED * sign(velocity.x)
	position += velocity * delta


func body_entered(body):
	if body is Character and not body.invincible:
		body.damage_with_knockback(global_position, DAMAGE)


func screen_entered():
	entered_screen = true


func screen_exited():
	if entered_screen:
		call_deferred("queue_free")
