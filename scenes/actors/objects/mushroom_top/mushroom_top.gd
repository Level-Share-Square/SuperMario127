extends StaticBody2D

onready var area = $Area2D
onready var body = $StaticBody2D
onready var collision_shape = $CollisionShape2D

var buffer := -5
var character = null

func _ready():
	if get_parent().mode != 1:
		var _connect = area.connect("body_entered", self, "enter_area")
		var _connect2 = area.connect("body_exited", self, "exit_area")

func can_collide_with(character):
	var direction = body.global_transform.y.normalized()
	
	if direction.y > 0.5:
		var line_center = body.global_position + (direction * buffer)
		var line_direction = Vector2(-direction.y, direction.x)
		var p1 = line_center + line_direction
		var p2 = line_center - line_direction
		var p = character.bottom_pos.global_position if (character.has_method("is_grounded") and !character.is_grounded()) else character.global_position
		var diff = p2 - p1
		var perp = Vector2(-diff.y, diff.x)
		var d = (p - p1).dot(perp)
		
		return sign(d) != 1
	else:
		return true
