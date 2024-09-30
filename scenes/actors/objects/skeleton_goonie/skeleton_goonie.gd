extends "res://scenes/actors/objects/goonie/goonie.gd"

onready var wing_body: = $StaticBody2D
onready var wingless_body: = $WinglessBody
onready var stomp_area_wing: = $StaticBody2D/StompAreaWing
onready var stomp_area_wingless: = $WinglessBody/StompArea
onready var bones_particles = $Sprite/BonesParticles
onready var head_particle = $Sprite/Head
onready var wall_check_A = $WinglessBody/WallCheckA
onready var wall_check_B = $WinglessBody/WallCheckB
onready var attack_area = $WinglessBody/AttackArea
onready var bomb_body = $StaticBody2D/BombBody
onready var bomb_area_check = $StaticBody2D/BombBody/DropCheck
onready var bomb_sprite = $StaticBody2D/BombBody/Bomb
onready var bomb_sfx = $StaticBody2D/BombBody/ExplosionSound
onready var bomb_particle = $StaticBody2D/BombBody/ExplodeParticle
onready var bomb_area_damage = $StaticBody2D/BombBody/DamageArea
onready var bomb_area_hit = $StaticBody2D/BombBody/CollisionCheck
onready var bones_sfx = $Bones
onready var poof = $Sprite/Poof
onready var hit_sfx = $Hit

var wingless_collision_mask: = 0
var wingless_collision_layer: = 0 
var bomb_collision_mask: = 0
var wingless_dir: = 1

var gravity: = 0.0
var gravity_scale: = 1.0
var wingless_spd: = 120.0
var inv_timer: = 0.0
var delete_timer: = 0.0
var flicker_timer: = 0.0
var bomb_delete_timer: = 0.0
var bomb_damage_timer: = 0.0

var bomb_velocity: = Vector2.ZERO
var velocity: = Vector2.ZERO
#this is the velocity without wings btw (named like this so it works with wind)
var wingless_snap = Vector2(0, 16)

var init_bomb: = false
var bomb_dead: = false
var sprite_visible: = true
var was_stomped: = false
var was_ground_pound: = false
var dropped_bomb: = false
var wingless: = false
var bombs: = false
var dead: = false
var hit: = false

func _set_properties():
	savable_properties = ["wingless", "speed", "bombs"]
	editable_properties = ["wingless", "speed", "bombs"]

func _set_property_values():
	set_property("wingless", wingless, true)
	set_property("speed", speed, true)
	set_property("bombs", bombs, true)

func update_wingless():
	if (wingless):
		wingless_body.collision_layer = wingless_collision_layer
		wingless_body.collision_mask = wingless_collision_mask
		sprite.animation = "wingless_walk"
		sprite.offset.x = 6
	else:
		wingless_body.collision_layer = 0
		wingless_body.collision_mask = 0
		sprite.animation = "flying"
		sprite.speed_scale = 1
		sprite.offset.x = -4

func goonie_ready():
	.goonie_ready()
	
	wingless_body = get_node("WinglessBody")
	bomb_body = get_node("StaticBody2D/BombBody")
	poof = get_node("Sprite/Poof")
	
	gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity
	wingless_collision_layer = wingless_body.collision_layer
	wingless_collision_mask = wingless_body.collision_mask
	bomb_collision_mask = bomb_body.collision_mask
	wingless_body.collision_layer = 0
	wingless_body.collision_mask = 0
	bomb_body.collision_mask = 0
	wingless_dir = facing_direction
	poof.emitting = false
	
	update_wingless()

func exploded(hit_pos:Vector2):
	hurt(hit_pos)

func create_coin(spawn_pos)->void :
	var object: = LevelObject.new()
	object.type_id = 1
	object.properties = []
	object.properties.append(spawn_pos)
	object.properties.append(Vector2(1, 1))
	object.properties.append(0)
	object.properties.append(true)
	object.properties.append(true)
	object.properties.append(true)
	var velocity_x = - 80 if randi() % 2 == 0 else 80
	object.properties.append(Vector2(velocity_x, - 300))
	get_parent().create_object(object, false)

func hurt(hit_pos:Vector2):
	if (inv_timer > 0):
		return
	
	if (not wingless):
		hit = true
		wingless = true
		wing_body.collision_layer = 0
		wing_body.collision_mask = 0
		stomp_area_wing.collision_layer = 0
		stomp_area_wing.collision_mask = 0
		bones_particles.emitting = true
		bones_particles.restart()
		wingless_dir = 1 if (sprite.flip_h) else -1
		flicker_timer = 0.001
		inv_timer = 1.5
		position.y += 2
		update_wingless()
		drop_bomb()
	else:
		dead = true
		hit = true
		delete_timer = 3.0
		sprite.offset.x = 99999999 # :333
		bones_particles.amount = 2
		bones_particles.emitting = true
		bones_particles.restart()
		wingless_body.collision_layer = 0
		wingless_body.collision_mask = 0
		hit_sfx.global_position = wingless_body.global_position
		
		if (sprite.flip_h): head_particle.texture = load("res://scenes/actors/objects/skeleton_goonie/headflip_h.png")
		head_particle.emitting = true
		head_particle.restart()
		create_coin(wingless_body.global_position)
	bones_sfx.play()
	hit_sfx.play()
	poof.emitting = true
	poof.restart()

func _process(delta):
	if (inv_timer > 0):
		inv_timer -= delta
		
		if (inv_timer <= 0):
			sprite_visible = true
			flicker_timer = 0.0
			hit = false
	
	if (delete_timer > 0):
		delete_timer -= delta
		
		if (delete_timer <= 0):
			queue_free()
	
	if (flicker_timer > 0):
		flicker_timer -= delta
		
		if (flicker_timer <= 0):
			sprite_visible = not sprite_visible
			flicker_timer = 0.015
	
	if (bomb_delete_timer > 0):
		bomb_delete_timer -= delta
		
		if (bomb_delete_timer <= 0):
			bomb_delete_timer = 0
			
			if (bomb_dead and is_instance_valid(bomb_body)):
				bomb_body.queue_free()
	
	sprite.self_modulate = Color.white if (sprite_visible) else Color.transparent

func drop_bomb():
	if (not is_instance_valid(bomb_body)):
		return
	if (bomb_body.get_parent() != wing_body or dropped_bomb):
		return
	
	bomb_velocity.y = gravity * (gravity_scale * 16)
	bomb_body.collision_mask = bomb_collision_mask
	dropped_bomb = true

func goonie_physics_process(delta: float):
	sprite.playing = true
	
	if not (mode != 1 and enabled):
		update_wingless()
		if (wingless):
			sprite.global_position = wingless_body.global_position
		else:
			sprite.global_position = wing_body.global_position
		bomb_sprite.visible = (bombs and not wingless)
		return
	if (dead):
		return
	
	if (not init_bomb):
		init_bomb = true
		
		if ((not bombs or (bombs and wingless)) and is_instance_valid(bomb_body)):
			bomb_body.queue_free()
	
	if (not wingless):
		.goonie_physics_process(delta)
		
		if not hit:
			for hit_body in stomp_area_wing.get_overlapping_bodies():
				if hit_body.name.begins_with("Character"):
					if hit_body.velocity.y > 0 and not hit_body.swimming:
						was_stomped = true
						if hit_body.big_attack or hit_body.invincible:
							was_ground_pound = true
						hit_body.position.y -= 2
						hit_body.velocity.y = -240
						hurt(hit_body.position)
			
			for hit_area in attack_area.get_overlapping_areas():
				if hit_area.has_method("is_hurt_area"):
					hurt(hit_area.global_position)
			
			for hit_body in attack_area.get_overlapping_bodies():
				if hit_body.name.begins_with("Character"):
					if hit_body.invincible or hit_body.attacking:
						hurt(hit_body.global_position)
					elif not hit and not dead:
						hit_body.damage_with_knockback(wingless_body.global_position)
			
			if (is_instance_valid(bomb_body) and bomb_area_check.get_overlapping_bodies().size() > 0):
				drop_bomb()
	else:
		
		if not hit:
			for hit_body in stomp_area_wingless.get_overlapping_bodies():
				if hit_body.name.begins_with("Character"):
					if hit_body.velocity.y > 0 and not hit_body.swimming:
						was_stomped = true
						if hit_body.big_attack or hit_body.invincible:
							was_ground_pound = true
						hit_body.position.y -= 2
						hit_body.velocity.y = -240
						hurt(hit_body.position)
			
			for hit_area in attack_area.get_overlapping_areas():
				if hit_area.has_method("is_hurt_area"):
					hurt(hit_area.global_position)
			
			for hit_body in attack_area.get_overlapping_bodies():
				if hit_body.name.begins_with("Character"):
					if hit_body.invincible or hit_body.attacking:
						hurt(hit_body.global_position)
					elif not hit and not dead:
						hit_body.damage_with_knockback(wingless_body.global_position)
		
		if (wall_check_A.is_colliding() or wall_check_B.is_colliding() or wingless_body.is_on_wall()):
			wingless_dir *= -1
			position.x += 2 * wingless_dir
		
		if (wingless_body.is_on_floor()):
			velocity.y = 0
			wingless_snap = Vector2(0, 12)
		else:
			velocity.y += gravity * gravity_scale
			wingless_snap = Vector2.ZERO
		
		wall_check_A.cast_to = Vector2(16 * wingless_dir, 0)
		wall_check_B.cast_to = wall_check_A.cast_to
		sprite.flip_h = (wingless_dir > 0)
		sprite.global_position = wingless_body.global_position
		velocity.x = wingless_spd * wingless_dir
		velocity = wingless_body.move_and_slide_with_snap(velocity, wingless_snap, Vector2.UP, true, 4, deg2rad(46))
	
	if (dropped_bomb and is_instance_valid(bomb_body)):
		if (not bomb_dead):
			bomb_velocity.y += gravity * gravity_scale
			bomb_velocity = bomb_body.move_and_slide(bomb_velocity)
		
			if (not bomb_area_hit.get_overlapping_bodies().empty()):
				bomb_dead = true
				bomb_delete_timer = 1.0
				bomb_damage_timer = 0.35
				bomb_body.collision_mask = 0
				bomb_sprite.visible = false
				bomb_particle.emitting = true
				bomb_particle.restart()
				bomb_sfx.play()
		elif (bomb_dead and bomb_damage_timer > 0):
			bomb_damage_timer -= delta
			for hit_body in bomb_area_damage.get_overlapping_bodies():
				if hit_body.has_method("exploded"):
					hit_body.exploded(bomb_body.global_position)
				elif hit_body.get_parent().has_method("exploded"):
					hit_body.get_parent().exploded(bomb_body.global_position)

func goonie_platform_area_exited(body):
	pass
