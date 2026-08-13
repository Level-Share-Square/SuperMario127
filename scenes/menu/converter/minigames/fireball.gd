extends KinematicBody2D


const IMPACT_SPRITE: StreamTexture = preload("res://scenes/actors/mario/particles/metal_sparkles.png")

onready var hit = $Hit
onready var last_hit = $LastHit
onready var shape_cast = $ShapeCast2D
onready var sprite = $Sprite
onready var paddle = $"%Paddle"

onready var initial_pos: Vector2 = position 
export var speed: float = 150
export var hit_damp: float = 0.85
export var play_width: float
var velocity : Vector2


func _physics_process(delta):
	shape_cast.target_position = velocity * delta
	shape_cast.force_shapecast_update()
	if shape_cast.is_colliding():
		paddle_hit(shape_cast.get_collider(0))
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		if is_equal_approx(velocity.x, 0):
			velocity.x = 250
		
		velocity = velocity.bounce(collision.get_normal())
		if velocity.length() > 200:
			velocity *= hit_damp
		
		var collider = collision.get_collider()
		if collider.name == "Ground":
			position = initial_pos
			velocity = Vector2.ZERO
			last_hit.play()
		elif collider.name.find("Box") > -1:
			collider.hit(self)
			hit.play()
		else:
			hit.play()
	
	if position.x <= initial_pos.x - play_width + 8 and velocity.x < 0:
		hit.play()
		velocity = velocity.bounce(Vector2.LEFT)
	
	if position.x >= initial_pos.x + play_width - 8  and velocity.x > 0:
		hit.play()
		velocity = velocity.bounce(Vector2.RIGHT)
	
	if position.y < 8 and velocity.y < 0:
		hit.play()
		velocity = velocity.bounce(Vector2.DOWN)
	
	position.x = clamp(position.x, initial_pos.x - play_width - 10, initial_pos.x + play_width + 10)
	position.y = max(position.y, 8)
	
	if abs(velocity.y) < 0.1:
		velocity.y = 0.1


func paddle_hit(paddle: Area2D):
	if velocity.y > -50 and global_position.y < paddle.global_position.y:
		var character: Character = paddle.character
		var altered_char_vel: Vector2 = Vector2(-character.velocity.x, min(character.velocity.y, 0))/3
		
		var bounce_normal: Vector2 = Vector2.UP
		bounce_normal.x = (global_position.x - paddle.global_position.x) / 82
		bounce_normal = bounce_normal.normalized()
		
		var relative_velocity: Vector2 = velocity - altered_char_vel
		var bounced_velocity: Vector2 = relative_velocity.bounce(bounce_normal)
		velocity = bounced_velocity + altered_char_vel/2
		
		hit.play()
		
		var tween: SceneTreeTween = create_tween()
		sprite.modulate = Color(2, 2, 2)
		sprite.scale = Vector2(1.25, 1.25)
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(sprite, "modulate", Color.white, 0.5)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.5)
		
		var impact_sprite := Sprite.new()
		impact_sprite.texture = IMPACT_SPRITE
		impact_sprite.region_enabled = true
		impact_sprite.region_rect.size = Vector2(14, 14)
		impact_sprite.rotation_degrees = 45
		impact_sprite.z_index = 32
		paddle.add_child(impact_sprite)
		impact_sprite.global_position = shape_cast.get_collision_point(0)
		
		var impact_tween: SceneTreeTween = create_tween()
		impact_tween.set_ease(Tween.EASE_IN)
		impact_tween.set_trans(Tween.TRANS_QUINT)
		impact_tween.tween_property(impact_sprite, "modulate", Color(1, 1, 1, 0), 0.15)
		impact_tween.tween_callback(impact_sprite, "queue_free")
		
		var impact_scale_tween: SceneTreeTween = create_tween()
		impact_tween.set_ease(Tween.EASE_OUT)
		impact_tween.set_trans(Tween.TRANS_QUART)
		impact_scale_tween.tween_property(impact_sprite, "scale", Vector2(2, 2), 0.1)
