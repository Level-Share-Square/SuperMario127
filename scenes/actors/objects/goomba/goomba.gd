extends GameObject

onready var sprite : AnimatedSprite = $Goomba/Sprite
onready var kinematic_body : KinematicBody2D = $Goomba
onready var attack_area : Area2D = $Goomba/AttackArea
onready var stomp_area : Area2D = $Goomba/StompArea
onready var player_detector : Area2D = $Goomba/PlayerDetector
onready var platform_detector : Area2D = $Goomba/PlatformDetector
onready var wall_check : RayCast2D = $Goomba/WallCheck
onready var wall_vacant_check : RayCast2D = $Goomba/WallVacantCheck
onready var pit_check : RayCast2D = $Goomba/PitCheck
onready var particles : Particles2D = $Goomba/Poof
onready var stomp_sound : AudioStreamPlayer = $Goomba/Stomp
onready var poof_sound : AudioStreamPlayer = $Goomba/Disappear
onready var hit_sound : AudioStreamPlayer = $Goomba/Hit
onready var anim_player : AnimationPlayer = $Goomba/AnimationPlayer
onready var bottom_pos : Node2D = $Goomba/BottomPos
onready var water_detector : Node2D = $Goomba/WaterDetector
onready var raycasts := [wall_check, wall_vacant_check, pit_check]
var dead := false

var gravity : float
var gravity_scale : float
var velocity := Vector2()

var walk_timer := 0.0
var walk_wait := 3.0
var boost_timer := 0.0
var hide_timer := 0.0
var delete_timer := 0.0
var speed := 30
var run_speed := 90
var shell_max_speed := 560
var accel := 5

var facing_direction := -1
var time_alive := 0.0

var hit := false
var snap := Vector2(0, 12)

var was_stomped := false
var was_ground_pound := false
var bounced := false

var loaded := true

var character : Character

export var top_point : Vector2

func jump() -> void:
	velocity.x = facing_direction * run_speed
	velocity.y = -225
	snap = Vector2(0, 0)
	position.y -= 2

func detect_player(body : Character) -> void:
	if character == null and enabled and body != null and !dead:
		character = body
		
		# warning-ignore: narrowing_conversion
		facing_direction = sign(character.global_position.x - body.global_position.x)
		if kinematic_body.is_on_floor():
			jump()

func on_visibility_changed(is_visible: bool) -> void:
	for raycast in raycasts:
		if is_instance_valid(raycast):
			raycast.enabled = is_visible

func on_hide() -> void:
	on_visibility_changed(false)

func on_show() -> void:
	on_visibility_changed(true)

func _ready() -> void:
	$VisibilityEnabler2D.connect("screen_exited", self, "on_hide")
	$VisibilityEnabler2D.connect("screen_entered", self, "on_show")
	on_visibility_changed($VisibilityEnabler2D.is_on_screen())
	# warning-ignore: return_value_discarded
	player_detector.connect("body_entered", self, "detect_player")
	CurrentLevelData.enemies_instanced += 1
	time_alive += float(CurrentLevelData.enemies_instanced) / 2.0
	gravity = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.gravity

func shell_hit(shell_pos : Vector2) -> void:
	if !hit:
		kill(shell_pos)
		
func exploded(explosion_pos : Vector2) -> void:
	if !hit:
		kill(explosion_pos)

func steely_hit(hit_pos : Vector2) -> void:
	if !hit:
		kill(hit_pos)

func create_coin() -> void:
	var object := LevelObject.new()
	object.type_id = 1
	object.properties = []
	object.properties.append(kinematic_body.global_position)
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	object.properties.append(true)
	var velocity_x = -80 if int(time_alive * 10) % 2 == 0 else 80
	object.properties.append(Vector2(velocity_x, -300))
	get_parent().create_object(object, false)

func kill(hit_pos : Vector2) -> void:
	if !hit and !dead:
		if is_instance_valid(kinematic_body):
			hit = true
			kinematic_body.set_collision_layer_bit(2, false)
			attack_area.set_collision_layer_bit(2, false)
			stomp_area.set_collision_layer_bit(2, false)
			kinematic_body.set_collision_mask_bit(2, false)
			attack_area.set_collision_mask_bit(2, false)
			stomp_area.set_collision_mask_bit(2, false)
			sprite.animation = "default"
			if was_stomped:
				stomp_sound.play()
				velocity = Vector2()
				anim_player.play("Stomped", -1, 2.0)
				boost_timer = 0.175
			else:
				hit = true
				hit_sound.play()
				sprite.playing = false
				var normal := sign((kinematic_body.global_position - hit_pos).x)
				velocity = Vector2(normal * 225, -225)
				position.y -= 2
				snap = Vector2(0, 0)

func _process(_delta) -> void:
	if mode == 1:
		# warning-ignore: integer_division
		sprite.frame = wrapi(OS.get_ticks_msec() / 166, 0, 4)

func _physics_process(delta : float) -> void:
	time_alive += delta
	
	if mode != 1 and enabled and loaded:
		var is_in_platform := false
		var platform_collision_enabled := false
		for platform_body in platform_detector.get_overlapping_areas():
			if platform_body.has_method("is_platform_area"):
				if platform_body.is_platform_area():
					is_in_platform = true
				if platform_body.get_parent().can_collide_with(kinematic_body):
					platform_collision_enabled = true
		kinematic_body.set_collision_mask_bit(4, platform_collision_enabled)
		for raycast in raycasts:
			raycast.set_collision_mask_bit(4, platform_collision_enabled)
		
		if is_instance_valid(kinematic_body):
			if !hit:
				physics_process_normal(delta, is_in_platform)
			else:
				physics_process_hit(delta, is_in_platform)

func physics_process_normal(delta: float, is_in_platform: bool) -> void:
	if water_detector.get_overlapping_areas().size() > 0:
		gravity_scale = 0.3
	else:
		gravity_scale = 1
	
	if !is_instance_valid(character):
		# Walk around randomly
		if walk_wait > 0:
			sprite.animation = "default"
			velocity.x = lerp(velocity.x, 0, delta * accel)
			walk_wait -= delta
			if walk_wait <= 0:
				walk_wait = 0
				walk_timer = float(int(time_alive * 10) % 3) + 1.0
				facing_direction *= -1 if int(time_alive * 10) % 2 == 0 else 1
		if walk_timer > 0:
			sprite.animation = "walking"
			velocity.x = lerp(velocity.x, facing_direction * speed, delta * accel)
			walk_timer -= delta
			if walk_timer <= 0:
				walk_timer = 0
				walk_wait = 3.0
	else:
		# Go towards the player
		sprite.animation = "walking"
		sprite.speed_scale = lerp(sprite.speed_scale, run_speed / speed, delta * accel)
		
		# warning-ignore: narrowing_conversion
		facing_direction = sign(character.global_position.x - kinematic_body.global_position.x)
		velocity.x = lerp(velocity.x, facing_direction * run_speed, delta * accel)
	
	sprite.flip_h = true if facing_direction == 1 else false
	
	# Ground collision
	if kinematic_body.is_on_floor():
		snap = Vector2(0, 0 if is_in_platform else 12)
		
		if is_instance_valid(character):
			pit_check.position.x = 16 * facing_direction
			wall_check.cast_to.x = 32 * facing_direction
			wall_vacant_check.cast_to.x = 96 * facing_direction
			if abs(wall_check.get_collision_normal().x) == 1 and wall_check.is_colliding() and !wall_vacant_check.is_colliding():
				jump()
			if !pit_check.is_colliding():
				jump()
				velocity.x *= 1.5
	else: # or not
		sprite.animation = "fall" if velocity.y >= 0 else "jump"
		snap = Vector2(0, 0)
	
	# Check the attack hitbox
	for hit_body in attack_area.get_overlapping_bodies():
		if hit_body.name.begins_with("Character"):
			if hit_body.attacking or hit_body.invincible:
				kill(hit_body.global_position)
			else:
				hit_body.damage_with_knockback(kinematic_body.global_position)
	# Same thing as above, but to check the spin attack area
	for hit_area in attack_area.get_overlapping_areas():
		if hit_area.has_method("is_hurt_area"):
			kill(hit_area.global_position)
	
	# Check the stomp hitbox
	if !hit: # Prevent goombas from entering that weird zombie state
		for hit_body in stomp_area.get_overlapping_bodies():
			if hit_body.name.begins_with("Character"):
				if hit_body.velocity.y > 0 and !hit_body.swimming:
					was_stomped = true
					if hit_body.big_attack or hit_body.invincible:
						was_ground_pound = true
					kill(hit_body.global_position)
	
	# Run physics
	velocity.y += gravity * gravity_scale
	velocity = kinematic_body.move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))

func physics_process_hit(delta: float, is_in_platform: bool) -> void:
	# Super professional timer technology
	if hide_timer > 0:
		hide_timer -= delta
		if hide_timer <= 0:
			hide_timer = 0
			particles.emitting = true
			sprite.visible = false
			delete_timer = 1.25
			poof_sound.play()
			velocity = Vector2()
			create_coin()
	if delete_timer > 0:
		delete_timer -= delta
		if delete_timer <= 0:
			delete_timer = 0
			queue_free()
			return
	
	if was_stomped:
		# Mario stomped on him
		if boost_timer > 0:
			if !was_ground_pound:
				character.velocity.y = 0
				if character.move_direction != 0:
					character.global_position.x += character.move_direction * 2
				character.global_position.y = lerp(character.global_position.y, (kinematic_body.global_position.y + top_point.y) - 25, delta * 6)
				
				var lerp_strength = 15
				lerp_strength = clamp(abs(character.global_position.x - kinematic_body.global_position.x), 0, 15)
				character.global_position.x = lerp(character.global_position.x, kinematic_body.global_position.x, delta * lerp_strength)
			boost_timer -= delta
			
			if boost_timer <= 0:
				boost_timer = 0
				hide_timer = 0.01
				if !was_ground_pound:
					character.velocity.y = -325
					if character.state != character.get_state_node("DiveState"):
						character.set_state_by_name("BounceState", delta)
			
	elif !dead:
		# The goomba is rolling around (from spin or off-center ground pound)
		sprite.rotation_degrees += (velocity.x / 15)
		#  velocity.length()         <   50
		if velocity.length_squared() < 2500 and kinematic_body.is_on_floor():
			dead = true
			hide_timer = 0.45
			velocity.x = 0
			sprite.rotation_degrees = 0
			anim_player.play("Stomped")
	
	if sprite.visible:
		# Ground collision
		if kinematic_body.is_on_floor():
			if kinematic_body.get_floor_normal().y == -1:
				velocity.x = lerp(velocity.x, 0, delta * 2.5)
			else:
				var normal := sign(kinematic_body.get_floor_normal().x)
				velocity.x = lerp(velocity.x, 225 * normal, delta)
			
			snap = Vector2(0, 0 if is_in_platform else 12)
		else: # or not
			snap = Vector2(0, 0)
		
		# Run physics
		velocity.y += gravity
		#kinematic_body.get_floor_normal()
		velocity = kinematic_body.move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
