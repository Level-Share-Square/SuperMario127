extends State

class_name SquishedState

var frames_squished := 0
var squish_y_difference := 0.0
var squish_amount := 0.0
var squish_start_frame_count := 0
var time_until_death := 0.0

func _ready():
	priority = 5
	disable_turning = true
	disable_movement = true

func _start_check(_delta):
	_update_squish_amount()
	return squish_amount > (0.1 if character.ground_check.is_colliding() else 0.5)

func _start(_delta):
	_update_squish_amount()
	if character.invulnerable_frames < 40:
		character.damage(0 if character.invulnerable else 3, "hit", 60)
	
	character.current_jump = 0
	frames_squished = 0
	time_until_death = 3.0

func _update_squish_amount():
	squish_amount = 0.0
	squish_y_difference = 0
	
	var y_from := character.bottom_pos.global_position.y
	if character.ground_check.is_colliding():
		y_from = character.ground_check.get_collision_point().y - 1
	
	var y_to := character.position.y - (0 if character.using_dive_collision else 6)
	
	# Is Mario's head inside terrain?
	if character.get_world_2d().direct_space_state.intersect_point(Vector2(character.position.x, y_to), 1, [self], 1).size() > 0:
		# Is Mario's bottom position inside terrain?
		if character.get_world_2d().direct_space_state.intersect_point(Vector2(character.position.x, y_from), 1, [self], 1).size() > 0:
			squish_y_difference = y_to - y_from
			squish_amount = 1.0
		else:
			# Do raycast
			var raycast := character.get_world_2d().direct_space_state.intersect_ray(
				Vector2(character.position.x, y_from), Vector2(character.position.x, y_to), [self], 1)
			if raycast.size() > 0:
				squish_y_difference = raycast["position"].y - y_to
				squish_amount = max(1.0 - (y_from - raycast["position"].y) / float(y_from - y_to), 0.0)

func _update(delta):
	if time_until_death > 0:
		time_until_death -= delta
		if time_until_death <= 0:
			time_until_death = 1.0
			character.damage(1)
	var sprite = character.sprite
	frames_squished += 1
	sprite.animation = "idleRight" if character.facing_direction == 1 else "idleLeft"
	
	_update_squish_amount()
	sprite.scale = Vector2(1.0 / (1.0 - squish_amount * 0.9), 1.0 - squish_amount * 0.9)
	sprite.offset.y = squish_y_difference * 0.5
	character.position.x += sprite.rotation

func _stop(_delta):
	var sprite = character.sprite
	frames_squished = 0
	sprite.scale = Vector2.ONE
	sprite.offset.y = 0

func _stop_check(_delta):
	return squish_amount == 0.0
