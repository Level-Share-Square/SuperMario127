extends Control

onready var collision_shape = $Area2D/CollisionShape2D
onready var animated_sprite = $AnimatedSprite
onready var reflection = $Reflection
var move_speed = 300.0
var collected = false

func destroy():
	queue_free()

func _physics_process(delta):
	if collected: return
	rect_position.x -= move_speed * delta * 0.5

func collect():
	if collected: return
	
	collected = true
	animated_sprite.animation = "collect"
	reflection.animation = "collect"

	get_tree().get_current_scene().collect_coin()
