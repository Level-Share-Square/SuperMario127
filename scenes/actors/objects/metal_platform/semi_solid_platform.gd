class_name SemiSolidPlatform
extends PhysicsBody2D

var buffer := -5
var movement := Vector2.ZERO


func can_collide_with(character):
	var direction = global_transform.y.normalized()
	
	var is_grounded = character.is_grounded() if character.has_method("is_grounded") else true
	# Some math that gives us useful vectors
	var line_center = global_position + (direction * buffer)
	var line_direction = Vector2(-direction.y, direction.x)
	var p1 = line_center + line_direction
	var p2 = line_center - line_direction
	var p = character.bottom_pos.global_position #if is_grounded else character.global_position
	#var velocity = character.velocity if character.get("velocity") != null else Vector2(0, 0) seems to be unused, uncomment if needed
	var diff = p2 - p1
	var perp = Vector2(-diff.y, diff.x)
	
	if !is_grounded:
		# If in the air, check for the velocity first
		# If we're trying to pass through it from the other way around,
		# cancel it
		var d = (character.velocity / 60.0 - movement).dot(perp)
		if d < 0:
			return false
		
		# Account for the movement of the platform to prevent clipping.
		p += movement
	else:
		p -= perp
	
	# Is p on the correct side?
	var d = (p - p1).dot(perp)
	return sign(d) != 1
