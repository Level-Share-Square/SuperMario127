extends PhysicsBody2D

onready var area = $Area2D
onready var collision_shape = $CollisionShape2D

var buffer := -5

func _ready():
	collision_shape.one_way_collision = false


# var prev_global_position = get_parent().last_position 
func can_collide_with(character):
	var direction = global_transform.y.normalized()
	
	# Use prev_is_grounded because calling is_grounded() is broken
	var is_grounded = character.prev_is_grounded if character.get("prev_is_grounded") != null else true
	
	# Some math that gives us useful vectors
	var line_center = global_position + (direction * buffer)
	var line_direction = Vector2(-direction.y, direction.x)
	var p1 = line_center + line_direction
	var p2 = line_center - line_direction
	
	var prev_global_position = get_parent().last_last_position 
	# Calculate object's velocity
	var object_velocity = (global_position - prev_global_position) / get_physics_process_delta_time()
	
	var character_velocity = character.global_position - character.last_last_position
	
	# Ensure character's velocity length is not zero to avoid division by zero
	var character_velocity_length = character_velocity.length()
	var steps = 1
	
	if character_velocity_length > 0:
		steps = int(object_velocity.length() / character_velocity_length) + 1

	
	
	# Calculate the platform's rotation angle
	var platform_rotation = global_transform.get_rotation()
	var global_up = Vector2(0, -1)
	var rotated_up = global_up.rotated(platform_rotation)
	
	for i in range(steps):

		var t = float(i) / steps
		var interpolated_position = prev_global_position.linear_interpolate(global_position, t)
		var interpolated_p1 = (p1 - prev_global_position).linear_interpolate(p1, t)
		var interpolated_p2 = (p2 - prev_global_position).linear_interpolate(p2, t)
		
		var diff = interpolated_p2 - interpolated_p1
		var perp = Vector2(-diff.y, diff.x)
		
		var p = character.bottom_pos.global_position
		
		if !is_grounded:
			var d = character_velocity.dot(perp)
			if d < 0:
				return false
			p -= (character_velocity).normalized()  # Adjusted for correct normalization
		else:
			p -= perp
		
		var d = (p - interpolated_p1).dot(perp)
		if true:
			
			# Check if the character is past the solid side
			var character_to_platform = p - interpolated_position
			var relative_angle = character_to_platform.angle() - rotated_up.angle()
			if abs(relative_angle) < PI / 2:
				return true
	
	return false
