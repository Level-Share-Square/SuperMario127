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
var gravity : float

func is_grounded():
	var check = grounded_check
	if !grounded_check.is_colliding():
		check = grounded_check_2
	return check.is_colliding()

func _physics_process(delta):
	var platform_collision_enabled = false
	for platform_body in platform_detector.get_overlapping_areas():
		if platform_body.has_method("is_platform_area"):
			if platform_body.get_parent().can_collide_with(body):
				platform_collision_enabled = true
	body.set_collision_mask_bit(4, platform_collision_enabled)
	grounded_check.set_collision_mask_bit(4, platform_collision_enabled)
	grounded_check_2.set_collision_mask_bit(4, platform_collision_enabled)

	for hit_body in area.get_overlapping_bodies():
		if hit_body.has_method("steely_hit") and abs(velocity.x) > 30:
			hit_body.steely_hit(global_position)
		elif hit_body.get_parent().has_method("steely_hit") and abs(velocity.x) > 30:
			hit_body.get_parent().steely_hit(global_position)

	gravity = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.gravity
	velocity.y += gravity

	var check = grounded_check
	if !grounded_check.is_colliding():
		check = grounded_check_2
		
	if check.is_colliding():
		if check.get_collision_normal().y == -1:
			velocity.x = lerp(velocity.x, 0, delta)
		else:
			var normal = 1
			if (check.get_collision_normal().x) < 0:
				normal = -1 + check.get_collision_normal().x
			else:
				normal = 1 - check.get_collision_normal().x
			velocity.x = lerp(velocity.x, 225 * normal, delta / 1.5)
			
	if abs(velocity.x) <= 30 and abs(check.get_collision_normal().y) > 0.75:
		body.set_collision_layer_bit(0, true)
		collider.disabled = true
		collider_stopped.disabled = false
	else:
		body.set_collision_layer_bit(0, false)
		collider.disabled = false
		collider_stopped.disabled = true

	rotation = 0
	velocity = body.move_and_slide(velocity)
	
	if !visiblity_notifier.is_on_screen():
		queue_free()
