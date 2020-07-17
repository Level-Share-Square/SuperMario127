extends GameObject

onready var area = $Area2D
onready var body = $StaticBody2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

var buffer := -5

func _ready():
	preview_position = Vector2(0, 92)
	collision_shape.one_way_collision = true
	# Fix for rotated platforms (Godot physics are weird)
	#body.rotation_degrees = -rotation_degrees
	#collision_shape.rotation_degrees = rotation_degrees

func can_collide_with(character):
	var direction = body.global_transform.y.normalized()
	
	var is_grounded = character.is_grounded() if character.has_method("is_grounded") else true
	var line_center = body.global_position + (direction * buffer)
	var line_direction = Vector2(-direction.y, direction.x)
	var p1 = line_center + line_direction
	var p2 = line_center - line_direction
	var p = character.bottom_pos.global_position if is_grounded else character.global_position
	var diff = p2 - p1
	var perp = Vector2(-diff.y, diff.x)
	# A threshold that should prevent clips
	if character.get("velocity") != null and !is_grounded:
		var d = character.velocity.dot(perp)
		if d < 0:
			return false
		
		p -= character.velocity.normalized()
	else:
		p -= perp
	
	var d = (p - p1).dot(perp)
	return sign(d) != 1
