extends GameObject

onready var sprite = $Goomba/Sprite
onready var kinematic_body = $Goomba
onready var attack_area = $Goomba/AttackArea
onready var stomp_area = $Goomba/StompArea
onready var bounce_area = $Goomba/BounceArea
onready var collision1 = $Goomba/CollisionShape2D
onready var collision2 = $Goomba/CollisionShape2D2
onready var collision3 = $Goomba/CollisionShape2D3
onready var collision4 = $Goomba/AttackArea/CollisionShape2D
onready var collision5 = $Goomba/BounceArea/CollisionShape2D
onready var collision6 = $Goomba/StompArea/CollisionShape2D
onready var collision7 = $Goomba/PlayerDetector/CollisionShape2D
onready var grounded_check = $Goomba/GroundedCheck
onready var grounded_check_2 = $Goomba/GroundedCheck2
onready var wall_check = $Goomba/WallCheck
onready var wall_vacant_check = $Goomba/WallVacantCheck
onready var pit_check = $Goomba/PitCheck
onready var particles = $Goomba/Poof
onready var player_detector = $Goomba/PlayerDetector
onready var stomp_sound = $Goomba/Stomp
onready var poof_sound = $Goomba/Disappear
onready var hit_sound = $Goomba/Hit
onready var anim_player = $Goomba/AnimationPlayer
onready var platform_detector = $Goomba/PlatformDetector
onready var bottom_pos = $Goomba/BottomPos
onready var raycasts = [grounded_check, grounded_check_2, wall_check, wall_vacant_check, pit_check]
var dead = false

var gravity : float
var velocity := Vector2()

var walk_timer = 0.0
var walk_wait = 3.0
var boost_timer = 0.0
var hide_timer = 0.0
var delete_timer = 0.0
var speed = 30
var run_speed = 90
var shell_max_speed = 560
var accel = 5

var facing_direction := -1
var time_alive = 0.0

var hit = false
var snap := Vector2(0, 12)

var was_stomped = false
var was_ground_pound = false
var bounced = false

var loaded = true

var character

export var top_point : Vector2

func jump():
	velocity.x = facing_direction * run_speed
	velocity.y = -225
	snap = Vector2(0, 0)
	position.y -= 2
	
func detect_player(body):
	if enabled and body.name.begins_with("Character") and !dead and character == null:
		character = body
		facing_direction = 1 if (character.global_position.x > body.global_position.x) else -1
		if grounded_check.is_colliding() or grounded_check_2.is_colliding():
			jump()

func _ready():
	sprite.playing = true
	player_detector.connect("body_entered", self, "detect_player")
	CurrentLevelData.enemies_instanced += 1
	time_alive += float(CurrentLevelData.enemies_instanced) / 2.0
	gravity = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.gravity

func shell_hit(shell_pos : Vector2):
	if !hit:
		kill(shell_pos)
		
func exploded(explosion_pos : Vector2):
	if !hit:
		kill(explosion_pos)

func steely_hit(hit_pos : Vector2):
	print("A")
	if !hit:
		kill(hit_pos)
	
func create_coin():
	var object = LevelObject.new()
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
		
func kill(hit_pos : Vector2):
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
				var normal = (kinematic_body.global_position - hit_pos).normalized().x
				if normal > 0 and normal < 1:
					normal = 1
				if normal <= 0 and normal > -1:
					normal = -1
				velocity = Vector2(normal * 225, -225)
				position.y -= 2
				snap = Vector2(0, 0)
				
func _process(_delta):
	if mode == 1:
		# warning-ignore: integer_division
		sprite.frame = wrapi(OS.get_ticks_msec() / 166, 0, 4)

func _physics_process(delta):
	time_alive += delta
	
	if mode != 1 and enabled and loaded:
		var is_in_platform = false
		var platform_collision_enabled = false
		for platform_body in platform_detector.get_overlapping_areas():
			if platform_body.has_method("is_platform_area"):
				if platform_body.is_platform_area():
					is_in_platform = true
				if platform_body.get_parent().can_collide_with(kinematic_body):
					platform_collision_enabled = true
		kinematic_body.set_collision_mask_bit(4, platform_collision_enabled)
		for raycast in raycasts:
			raycast.set_collision_mask_bit(4, platform_collision_enabled)
		if !hit:
			if is_instance_valid(kinematic_body):
				var level_size = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.size
				if kinematic_body.global_position.y > (level_size.y * 32) + 128:
					queue_free()
						
				if !is_instance_valid(character):
					if walk_wait > 0:
						sprite.animation = "default"
						velocity.x = lerp(velocity.x, 0, delta * accel)
						walk_wait -= delta
						if walk_wait <= 0:
							walk_wait = 0
							walk_timer = float(int(time_alive * 10) % 3) + 1.0
							facing_direction = -facing_direction if int(time_alive * 10) % 2 == 0 else facing_direction
					if walk_timer > 0:
						sprite.animation = "walking"
						velocity.x = lerp(velocity.x, facing_direction * speed, delta * accel)
						walk_timer -= delta
						if walk_timer <= 0:
							walk_timer = 0
							walk_wait = 3.0
				else:
					sprite.animation = "walking"
					sprite.speed_scale = lerp(sprite.speed_scale, run_speed / speed, delta * accel)
					facing_direction = 1 if (character.global_position.x > kinematic_body.global_position.x) else -1
					velocity.x = lerp(velocity.x, facing_direction * run_speed, delta * accel)
				if (
					kinematic_body.global_position.x < -64 or 
					kinematic_body.global_position.x > (level_size.x * 32) + 64
				):
					queue_free()
				sprite.flip_h = true if facing_direction == 1 else false
				
				if !grounded_check.is_colliding() and !grounded_check_2.is_colliding():
					if velocity.y >= 0:
						sprite.animation = "fall"
					else:
						sprite.animation = "jump"
					snap = Vector2(0, 0)
				else:
					if !is_in_platform:
						snap = Vector2(0, 12)
					else:
						snap = Vector2(0, 0)

					velocity.y = 0
					if is_instance_valid(character):
						grounded_check.position.x = 8 * facing_direction
						grounded_check_2.position.x = -8 * facing_direction
						pit_check.position.x = 16 * facing_direction
						wall_check.cast_to.x = 32 * facing_direction
						wall_vacant_check.cast_to.x = 96 * facing_direction
						if abs(wall_check.get_collision_normal().x) == 1 and wall_check.is_colliding() and !wall_vacant_check.is_colliding():
							jump()
						if !pit_check.is_colliding():
							jump()
							velocity.x *= 1.5

				velocity.y += gravity
				velocity = kinematic_body.move_and_slide_with_snap(velocity, snap, Vector2.UP.normalized(), true, 4, deg2rad(46))

				for hit_body in attack_area.get_overlapping_bodies():
					if hit_body.name.begins_with("Character"):
						if hit_body.attacking or hit_body.invincible:
							kill(hit_body.global_position)
						else:
							hit_body.damage_with_knockback(kinematic_body.global_position)

				for hit_body in stomp_area.get_overlapping_bodies():
					if hit_body.name.begins_with("Character"):
						if hit_body.velocity.y > 0:
							was_stomped = true
							if character.big_attack:
								was_ground_pound = true
							kill(hit_body.global_position)
		else:
			var level_size = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.size
			if kinematic_body.global_position.y > (level_size.y * 32) + 128:
				queue_free()
					
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
			if was_stomped:
				if boost_timer > 0:
					if !was_ground_pound:
						character.velocity.y = 0
						character.velocity.x = 0
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
				sprite.rotation_degrees += (velocity.x / 15)
				var check = grounded_check
				if !grounded_check.is_colliding():
					check = grounded_check_2
				if abs(velocity.x) < 50 and check.get_collision_normal().y == -1:
					dead = true
					hide_timer = 0.45
					velocity.x = 0
					sprite.rotation_degrees = 0
					anim_player.play("Stomped")

			if sprite.visible:
				velocity.y += gravity
				velocity = kinematic_body.move_and_slide_with_snap(velocity, snap, Vector2.UP.normalized(), true, 4, deg2rad(46))
				if grounded_check.is_colliding() or grounded_check_2.is_colliding():
					var check = grounded_check
					if !grounded_check.is_colliding():
						check = grounded_check_2
					if check.get_collision_normal().y == -1:
						velocity.x = lerp(velocity.x, 0, delta * 2.5)
					else:
						var normal = 0
						if (check.get_collision_normal().x) < 0:
							normal = -1
						else:
							normal = 1
						velocity.x = lerp(velocity.x, 225 * normal, delta)

					if is_in_platform:
						snap = Vector2(0, 0)
					else:
						snap = Vector2(0, 12)
				else:
					snap = Vector2(0, 0)
