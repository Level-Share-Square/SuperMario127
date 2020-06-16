extends GameObject

onready var sprite = $Goomba/Sprite
onready var body = $Goomba
onready var attack_area = $Goomba/AttackArea
onready var stomp_area = $Goomba/StompArea
onready var bounce_area = $Goomba/BounceArea
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
var dead = false

var gravity : float
var velocity := Vector2()

var walk_timer = 0.0
var walk_wait = 3.0
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
var squash_amount = 1
var bounced = false

var character

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
	player_detector.connect("body_entered", self, "detect_player")
	CurrentLevelData.enemies_instanced += 1
	time_alive += float(CurrentLevelData.enemies_instanced) / 2.0
	gravity = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.gravity

func shell_hit(shell_pos : Vector2):
	if is_instance_valid(body):
		kill(shell_pos)
		
func exploded(explosion_pos : Vector2):
	kill(explosion_pos)
		
func kill(hit_pos : Vector2):
	if !hit:
		if is_instance_valid(body):
			hit = true
			body.set_collision_mask_bit(2, false)
			attack_area.set_collision_mask_bit(2, false)
			stomp_area.set_collision_mask_bit(2, false)
			sprite.animation = "default"
			if was_stomped:
				stomp_sound.play()
				velocity = Vector2()
			else:
				var normal = (body.global_position - hit_pos).normalized().x
				facing_direction = int(-normal)
				hit_sound.play()
				velocity = Vector2(normal * 225, -275)
				position.y -= 2
				particles.position = Vector2(0, 6)
				sprite.playing = false
				hide_timer = 0.5

func _physics_process(delta):
	time_alive += delta
	if delete_timer > 0 and dead:
		delete_timer -= delta
		if delete_timer <= 0:
			delete_timer = 0
			queue_free()
	
	if mode != 1 and enabled and !dead:
		if !hit:
			if is_instance_valid(body):
				var level_size = CurrentLevelData.level_data.areas[CurrentLevelData.area].settings.size
				if body.global_position.y > (level_size.y * 32) + 128:
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
					facing_direction = 1 if (character.global_position.x > body.global_position.x) else -1
					velocity.x = lerp(velocity.x, facing_direction * run_speed, delta * accel)
				if (
					body.global_position.x < -64 or 
					body.global_position.x > (level_size.x * 32) + 64
				):
					queue_free()
				sprite.flip_h = true if facing_direction == 1 else false
				
				if !grounded_check.is_colliding() and !grounded_check_2.is_colliding():
					if velocity.y >= 0:
						sprite.animation = "fall"
					else:
						sprite.animation = "jump"
				else:
					snap = Vector2(0, 20)
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
				velocity = body.move_and_slide_with_snap(velocity, snap, Vector2.UP.normalized(), true, 4, deg2rad(46))

				for hit_body in attack_area.get_overlapping_bodies():
					if hit_body.name.begins_with("Character"):
						if hit_body.attacking:
							kill(hit_body.global_position)
						else:
							hit_body.damage_with_knockback(body.global_position)
			
				for hit_body in stomp_area.get_overlapping_bodies():
					if hit_body.name.begins_with("Character"):
						if hit_body.velocity.y > 0:
							was_stomped = true
							kill(hit_body.global_position)
		else:
			if hide_timer > 0:
				hide_timer -= delta
				if hide_timer <= 0:
					hide_timer = 0
					particles.emitting = true
					sprite.visible = false
					delete_timer = 1.25
					poof_sound.play()
					velocity = Vector2()
			if delete_timer > 0:
				delete_timer -= delta
				if delete_timer <= 0:
					delete_timer = 0
					queue_free()
			if was_stomped:
				var is_overlapping = false
				for body in bounce_area.get_overlapping_bodies():
					if body == character:
						is_overlapping = true
				
				if !is_overlapping:
					sprite.scale = sprite.scale.linear_interpolate(Vector2(0, 1.5), delta * 25)
					sprite.offset = sprite.offset.linear_interpolate(Vector2(0, -8), delta * 25)
				else:
					if character.velocity.y >= 0:
						character.velocity.y -= (character.velocity.y/5)
						if character.velocity.y <= -15:
							character.velocity.y = -275
					
			elif sprite.visible:
				sprite.rotation_degrees = lerp_angle(sprite.rotation_degrees, velocity.y / 15, delta * 200) * -facing_direction
				velocity.y += gravity
				position += velocity * delta
