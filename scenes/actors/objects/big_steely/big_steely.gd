extends GameObject

onready var area = $Steely/Area2D
onready var platform_detector = $Steely/PlatformDetector
onready var body = $Steely

onready var grounded_check = $Steely/Check1
onready var grounded_check_2 = $Steely/Check2

#onready var collider = $Steely/SteelieCollider/CollisionShapeSteelie
#onready var collider_stopped = $Steely/CollisionShapeStopped

onready var visiblity_notifier = $Steely/VisibilityNotifier2D

var velocity := Vector2(0, 0)
var prev_pos := Vector2(0, 0)
var gravity : float

var fade_time = 0.0
var alpha = 0.0
var initial_scale
var actual_scale

func is_grounded():
	var check = grounded_check
	if !grounded_check.is_colliding():
		check = grounded_check_2
	return check.is_colliding()
	
func _ready():
	initial_scale = scale / 1.5
	actual_scale = scale
	scale = initial_scale
	fade_time = 0.5
	modulate = Color(1, 1, 1, 0)

func _physics_process(delta):
	if fade_time != 0:
		alpha = lerp(alpha, 1.0, delta * 3.333)
		scale = scale.linear_interpolate(actual_scale, delta * 3.333)
		modulate = Color(1, 1, 1, alpha)
		fade_time -= delta
		if fade_time <= 0:
			fade_time = 0
			alpha = 1.0
			scale = actual_scale
			modulate = Color(1, 1, 1, alpha)
		return
	# Use the position difference to calculate velocity
	# (the one in the physics body isn't accurate
	# for hitting Mario)
	var new_pos = body.position
	var actual_velocity = (new_pos - prev_pos) / delta / 120
	prev_pos = new_pos
	
	var should_hit = actual_velocity.length_squared() > 0.25
	
	var platform_collision_enabled = false
	for platform_body in platform_detector.get_overlapping_areas():
		if platform_body.has_method("is_platform_area"):
			if platform_body.get_parent().can_collide_with(body):
				platform_collision_enabled = true
	body.set_collision_mask_bit(4, platform_collision_enabled)
	grounded_check.set_collision_mask_bit(4, platform_collision_enabled)
	grounded_check_2.set_collision_mask_bit(4, platform_collision_enabled)

	if should_hit:
		for hit_body in area.get_overlapping_bodies():
			if hit_body.has_method("steely_hit"):
				hit_body.steely_hit(global_position)
			elif hit_body.get_parent().has_method("steely_hit"):
				hit_body.get_parent().steely_hit(global_position)

	gravity = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.gravity
	#body.apply_central_impulse(Vector2(0, gravity))
	velocity.y += gravity

	var check = grounded_check
	if !grounded_check.is_colliding():
		check = grounded_check_2
	
	if !should_hit:# and abs(check.get_collision_normal().y) > 0.75:
		body.set_collision_layer_bit(0, true)
		#collider.disabled = true
		#collider_stopped.disabled = false
	else:
		body.set_collision_layer_bit(0, false)
		#collider.disabled = false
		#collider_stopped.disabled = true
		
	if check.is_colliding():
		velocity.x = lerp(velocity.x, 0, delta / 4)

	rotation = 0
	velocity = body.move_and_slide(velocity)
	
	if !visiblity_notifier.is_on_screen() or global_position.y > (level_area.settings.size.y * 32) + 96:
		queue_free()
