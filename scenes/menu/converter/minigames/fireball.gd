extends KinematicBody2D

onready var hit = $Hit
onready var last_hit = $LastHit

onready var initial_pos: Vector2 = position 
export var speed: float = 150
export var play_width: float
var velocity: Vector2


func _ready():
	velocity = Vector2(1, 1).normalized() * speed


func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		var collider = collision.get_collider()
		if collider.name == "Ground":
			position = initial_pos
			velocity = Vector2(1, 1).normalized() * speed
			last_hit.play()
		else:
			hit.play()
	
	if position.x <= initial_pos.x - play_width:
		hit.play()
		velocity = velocity.bounce(Vector2.LEFT)
	
	if position.x >= initial_pos.x + play_width:
		hit.play()
		velocity = velocity.bounce(Vector2.RIGHT)
	
	if position.y < 8:
		hit.play()
		velocity = velocity.bounce(Vector2.DOWN)

	if abs(velocity.y) < 0.1:
		velocity.y = 0.1


func area_entered(area):
	if velocity.y > 0 and global_position.y < area.global_position.y:
		velocity = velocity.bounce(Vector2.UP)
		var parent_length: float = area.get_parent().velocity.length_squared()
		parent_length = min(parent_length, velocity.length_squared() * 2)
		if velocity.length_squared() < parent_length:
			velocity *= parent_length / velocity.length_squared()
		hit.play()
