extends GameObject

onready var area = $Steely/Area2D
onready var break_detector = $Steely/BreakDetector
onready var platform_detector = $Steely/PlatformDetector
onready var water_detector = $Steely/WaterDetector
onready var body = $Steely
onready var sound = $Steely/AudioStreamPlayer
onready var sprite = $Steely/Sprite

onready var break_particle = $Steely/BreakParticle
onready var dust_particle = $Steely/DustParticle

onready var grounded_check = $Steely/Check1
onready var grounded_check_2 = $Steely/Check2

onready var despawn_timer = $DespawnTimer 

#onready var collider = $Steely/SteelieCollider/CollisionShapeSteelie
#onready var collider_stopped = $Steely/CollisionShapeStopped

onready var visiblity_notifier = $Steely/VisibilityNotifier2D

var velocity := Vector2(0, 0)
var prev_pos := Vector2(0, 0)
var gravity : float
var gravity_scale : float
var should_hit := false

var fade_time = 0.0
var alpha = 0.0
var initial_scale
var actual_scale

var broken := false
var break_timer := 0.0
var time_alive := 0.0

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

	despawn_timer.connect("timeout", self, "_on_despawn_timer_timeout")
	
func disable_all_descendants(node):
	for child in node.get_children():
		if child is CollisionShape2D:
			child.disabled = true
		disable_all_descendants(child)
	
func destroy():
	broken = true
	disable_all_descendants(self)
	sound.play()
	create_coin()
	dust_particle.emitting = true
	break_particle.emitting = true
	sprite.visible = false
	break_timer = 1.5

func create_coin(): #creates a coin
	time_alive += 1
	time_alive += (time_alive/3*5/10)
	var object = LevelObject.new()
	object.type_id = 40
	object.properties = []
	object.properties.append(body.global_position)
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	object.properties.append(true)
	var power = int(time_alive*100) % 80
	var velocity_x = -power if int(time_alive * 10) % 2 == 0 else power
	object.properties.append(Vector2(velocity_x, -300)) #makes the coin move around and fly in the air when the block breaks
	get_parent().create_object(object, false) #finishes the object creation

func _physics_process(delta):
	time_alive += delta
	if !broken:
		if water_detector.get_overlapping_areas().size() > 0:
			if gravity_scale == 1:
				velocity.y /= 4
			gravity_scale = 0.3
		else:
			gravity_scale = 1
		
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
		
		should_hit = actual_velocity.length_squared() > 0.25
		
		var platform_collision_enabled = false
		for platform_body in platform_detector.get_overlapping_areas():
			if platform_body.has_method("is_platform_area"):
				if platform_body.get_parent().can_collide_with(body):
					platform_collision_enabled = !broken
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
		velocity.y += gravity * gravity_scale
	
		var check = grounded_check
		if !grounded_check.is_colliding():
			check = grounded_check_2
		
		if !should_hit and !broken:# and abs(check.get_collision_normal().y) > 0.75:
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
		
		if !visiblity_notifier.is_on_screen() or global_position.y > (level_area.settings.bounds.end.y * 32) + 96:
			queue_free()

		for hit_body in break_detector.get_overlapping_bodies():
			if hit_body.name.begins_with("Character") and hit_body.invincible:
				destroy()
	else:
		for child in get_children():
			if child is CollisionShape2D:
				child.disabled = true # i dont feel like doing proper debugging so i'm doing this
		break_timer -= delta
		if break_timer <= 0:
			break_timer = 0
			queue_free()

func setup_despawn_timer(wait_time): #for now, this is only called by the steely spawner
	despawn_timer.wait_time = wait_time 
	despawn_timer.start()
	
func _on_despawn_timer_timeout():
	if !visiblity_notifier.is_on_screen():
		queue_free()
