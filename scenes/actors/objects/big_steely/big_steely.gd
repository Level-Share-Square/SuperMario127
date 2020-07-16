extends GameObject

onready var area = $KinematicBody2D/Area2D
onready var platform_detector = $KinematicBody2D/PlatformDetector
onready var body = $KinematicBody2D

onready var grounded_check = $KinematicBody2D/Check1
onready var grounded_check_2 = $KinematicBody2D/Check2

onready var collider = $KinematicBody2D/CollisionShape2D
onready var collider_stopped = $KinematicBody2D/CollisionShapeStopped

onready var visiblity_notifier = $KinematicBody2D/VisibilityNotifier2D

var velocity := Vector2(0, 0)
var prev_pos := Vector2(0, 0)
var gravity : float

func is_grounded():
	var check = grounded_check
	if !grounded_check.is_colliding():
		check = grounded_check_2
	return check.is_colliding()

func _physics_process(delta):
	# Use the position difference to calculate velocity
	# (the one in the physics body isn't accurate
	# for hitting Mario)
	var new_pos = body.position
	var actual_velocity = (new_pos - prev_pos) / delta / 120
	prev_pos = new_pos
	
	var should_hit = actual_velocity.length_squared() > 0.09
	
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
	velocity.y += gravity

	var check = grounded_check
	if !grounded_check.is_colliding():
		check = grounded_check_2
	
	if !should_hit:# and abs(check.get_collision_normal().y) > 0.75:
		body.set_collision_layer_bit(0, true)
		collider.disabled = true
		collider_stopped.disabled = false
	else:
		body.set_collision_layer_bit(0, false)
		collider.disabled = false
		collider_stopped.disabled = true
		
	if check.is_colliding():
		velocity.x = lerp(velocity.x, 0, delta / 4)

	rotation = 0
	velocity = body.move_and_slide(velocity)
	
	if !visiblity_notifier.is_on_screen():
		queue_free()
