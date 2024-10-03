extends GameObject

const rainbow_animation_speed := 500

onready var body: KinematicBody2D = $Body
onready var sprite: = $Body/Sprite
onready var recolorable_sprite: = $Body/Recolorable
onready var player_detector: = $Body/PlayerDetector
onready var attack_area: = $Body/AttackArea
onready var hit_sound: = $Body/Hit
onready var poof_sfx: = $Body/Disappear
onready var poof: = $Body/Poof

var color := Color.green

var velocity: = Vector2.ZERO
var character_position: = Vector2.ZERO

var character: Character

var rainbow: = false
var wander: = false
var fire: = false
var hit: = false
var bouncy_fire := false

var gravity: = 0.0
var gravit_scale: = 1.0
var wander_timer: = 0.0
var wander_pause_timer: = 1.0
var fire_pause: = 0.0
var fire_buffer: = 0.0
var hide_timer: = 0.0
var delete_timer: = 0.0

var facing_direction: = 1
var fire_count: = 0

export var jump_height = 60
export var super_jump_height = 280
export var walk_spd = 48
export var max_fire_pause = 3.0

func _set_properties():
	savable_properties = ["wander", "fire", "color", "rainbow", "bouncy_fire"]
	editable_properties = ["wander", "fire", "bouncy_fire", "color", "rainbow"]
	
func _set_property_values():
	set_property("wander", wander, true)
	set_property("fire", fire, true)
	set_property("color", color, true)
	set_property("rainbow", rainbow, true)
	set_property("bouncy_fire", bouncy_fire, true)

func _ready():
	gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity
	
	if scale.x < 0:
		scale.x = abs(scale.x)
		facing_direction = -facing_direction
		sprite.scale.x = facing_direction

func _process(delta):
	if rainbow:
		color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	recolorable_sprite.modulate = color
	recolorable_sprite.scale = sprite.scale
	recolorable_sprite.frame = sprite.frame
	recolorable_sprite.playing = sprite.playing
	recolorable_sprite.animation = sprite.animation + "Recolorable"
	recolorable_sprite.visible = sprite.visible
	recolorable_sprite.rotation = sprite.rotation
	
	if not (mode != 1 and enabled):
		return
	
	if (fire):
		wander = false
		wander_pause_timer = 0
		wander = 0
	
	if (wander):
		if (wander_pause_timer > 0):
			wander_pause_timer -= delta
		
			if (wander_pause_timer <= 0):
				if (randi() % 10) <= 5:
					facing_direction *= -1
					sprite.scale.x = facing_direction
				wander_pause_timer = 0
				wander_timer = rand_range(0.5, 2.5)
		
		if (wander_timer > 0):
			wander_timer -= delta
			
			if (wander_timer <= 0):
				wander_timer = 0
				wander_pause_timer = rand_range(0.5, 1)

func hit(hit_pos: Vector2):
	if (hit):
		return
	
	hit = true
	hit_sound.play()
	sprite.playing = false
	var normal: = sign((body.global_position - hit_pos).x)
	velocity = Vector2(normal * 225, - 225)
	hide_timer = 3.0
	position.y -= 2

func create_coin()->void :
	var object: = LevelObject.new()
	object.type_id = 1
	object.properties = []
	object.properties.append(body.global_position)
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	object.properties.append(true)
	var velocity_x = - 80 if randi() % 2 == 0 else 80
	object.properties.append(Vector2(velocity_x, - 300))
	get_parent().create_object(object, false)

func _physics_process(delta):
	if not (mode != 1 and enabled):
		return
	
	if (not hit):
		sprite.playing = true
		
		if (not player_detector.get_overlapping_bodies().empty()):
			if (character == null):
				character = player_detector.get_overlapping_bodies()[0]
				fire_pause = 0.01
			
			if (fire):
				character_position = character.global_position
				
				if (fire_pause > 0):
					fire_pause -= delta
					
					if (fire_pause <= 0):
						fire_pause = max_fire_pause
						fire_count = 0.0
						fire_buffer = 0.001
						sprite.play("jumpTransition")
				
				if (sprite.animation == "jumpTransition" and sprite.frame >= 2):
					spawn_fireball()
					
					if (fire_count <= 0):
						sprite.play("jumpLoop")
					else:
						fire_count -= 1
						sprite.frame = 0
				elif (sprite.animation == "jumpLoop" and sprite.frame >= 2 and fire_count <= 0):
					sprite.play("default")
		elif (fire):
			sprite.animation = "default"
			character = null
		
		if (is_instance_valid(character)):
			if (abs(body.global_position.x - character.global_position.x) <= 100 and 
				(body.global_position.y - character.global_position.y) > 24 and
				sprite.animation == "default" and not fire
			):
				sprite.play("jumpTransition")
		
		for hit_area in attack_area.get_overlapping_areas():
			if hit_area.has_method("is_hurt_area") and not rainbow:
				hit(hit_area.global_position)
		
		for hit_body in attack_area.get_overlapping_bodies():
			if hit_body.name.begins_with("Character"):
				if (hit_body.attacking or hit_body.invincible) and not rainbow:
					hit(hit_body.global_position)
				else :
					hit_body.damage_with_knockback(body.global_position)
		
		if (not body.is_on_floor()):
			velocity.y += (gravity * gravit_scale)
		else:
			if (wander_timer > 0 or (character != null and wander)):
				velocity.y = -jump_height
			
			if (not fire):
				if (sprite.animation == "jumpTransition" and sprite.frame >= 2):
					velocity.y = -super_jump_height
					sprite.play("jumpLoop")
				elif (sprite.animation == "jumpLoop"):
					sprite.play("default")
		
		if (wander_timer > 0 or (character != null)):
			if (character == null):
				if (body.is_on_wall()):
					facing_direction *= -1
					sprite.scale.x = facing_direction
			else:
				facing_direction = sign(body.global_position.x - character.global_position.x)
				sprite.scale.x = facing_direction
			
			if (wander):
				velocity.x = lerp(velocity.x, walk_spd * -facing_direction, 0.075)
		else:
			velocity.x = 0
	elif hide_timer > 0:
		hide_timer -= delta
		
		sprite.rotation_degrees += (velocity.x / 15)
		velocity.y += (gravity * gravit_scale)
		if velocity.length_squared() < 2500 and body.is_on_floor():
			hide_timer = 0
		
		if (hide_timer <= 0):
			delete_timer = 1.0
			hide_timer = 0
			poof.emitting = true
			poof_sfx.play()
			poof.restart()
			create_coin()
	elif (delete_timer > 0):
		delete_timer -= delta
		velocity = Vector2.ZERO
		body.collision_layer = 0
		body.collision_mask = 0
		sprite.visible = false
		
		if (delete_timer <= 0):
			queue_free()
			return
	
	velocity = body.move_and_slide(velocity, Vector2.UP)


func calculate_fireball_velocity(source_position: Vector2, target_position: Vector2, gravity: float) -> Vector2:
#	# blud's aim kind sucks when you're further away from it idk im not that good at math :emoji_401:
#	var height_offset = min(body.global_position.y, target_pos.y) - 90
#	var y_vel = sqrt((body.global_position.y - height_offset) * 90 * gravity)
#
#	var peak_t = y_vel / gravity
#	var fall_t = sqrt((target_pos.y - height_offset) / gravity)
#	var total_t = peak_t + fall_t
#
#	var pos_delta = target_pos - body.global_position
#	pos_delta.y = 0;
#
#	var distance = pos_delta.length()
#	var final_v = pos_delta.normalized() * (distance / total_t) * 30
#	final_v.y = (-y_vel)
	var new_velocity := Vector2.ZERO
	var displacement := target_position-source_position
	var arc_height := target_position.y-source_position.y-64
	
	if displacement.y > arc_height:
		var time_up = sqrt(-2 * arc_height/gravity)
		var time_down = sqrt(2 * (displacement.y - arc_height)/gravity)
		
		new_velocity.y = -sqrt(-2 * gravity * arc_height)
		new_velocity.x = displacement.x / (time_up+time_down)
	
	#for some reason dividing by .13 makes the code work perfectly, so we're going to roll with it
	return new_velocity/.13

func spawn_fireball():
	var object: = LevelObject.new()
					
	object.type_id = 134
	object.properties = []
	object.properties.append(body.global_position - Vector2(0, 8))
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	object.properties.append(calculate_fireball_velocity(body.global_position - Vector2(0, 8), character_position, gravity*gravit_scale))
	object.properties.append(bouncy_fire)
	get_parent().create_object(object, false)
