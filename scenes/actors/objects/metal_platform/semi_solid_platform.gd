class_name SemiSolidPlatform
extends PhysicsBody2D

const THRESHOLD: float = 2.5

var buffer := -5
var movement := Vector2.ZERO


func can_collide_with(character):
	var direction = global_transform.y.normalized()
	
	var is_grounded = character.is_grounded() if character.has_method("is_grounded") else true
	var line_center = global_position + (direction * buffer)
	var line_direction = Vector2(-direction.y, direction.x)
	var p1 = line_center + line_direction
	var p2 = line_center - line_direction
	var p = character.bottom_pos.global_position
	var velocity = (character.velocity / 60.0) if character.get("velocity") != null else Vector2.ZERO
	var diff = p2 - p1
	var perp = Vector2(-diff.y, diff.x)
	
	if is_grounded:
		p -= perp
	
	var perp_norm = perp.normalized()
	var vel_dir = (velocity - movement).dot(perp_norm)
	var dynamic_threshold = vel_dir / THRESHOLD + 0.01
	# Is p on the correct side?
	var side = (p - p1).dot(perp_norm)
	var correct_side = side < dynamic_threshold
	
	# If we're trying to pass through it from the underside, cancel collision
	if not is_grounded and vel_dir < 0:
		if "apply_velocity" in self:
			#self.apply_velocity = false
			pass
		return false
	
	if "apply_velocity" in self and correct_side:
		self.apply_velocity = true
	return correct_side
