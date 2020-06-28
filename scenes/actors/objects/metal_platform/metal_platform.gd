extends GameObject

onready var area = $Area2D
onready var body = $StaticBody2D
onready var collision_shape = $StaticBody2D/CollisionShape2D

var buffer := -5

func _ready():
	preview_position = Vector2(0, 92)
	collision_shape.one_way_collision = true

func can_collide_with(character):
	var direction = body.global_transform.y.normalized()
	
	if direction.y > 0.5:
		var line_center = body.global_position + (direction * buffer)
		var line_direction = Vector2(-direction.y, direction.x)
		var p1 = line_center + line_direction
		var p2 = line_center - line_direction
		var p = character.bottom_pos.global_position
		var diff = p2 - p1
		var perp = Vector2(-diff.y, diff.x)
		var d = (p - p1).dot(perp)
		
		return sign(d) != 1
	else:
		return true
