extends GameObject

onready var sprite : AnimatedSprite = $CheepCheep/Sprite
onready var color_sprite : AnimatedSprite = $CheepCheep/ColorSprite
onready var kinematic_body : KinematicBody2D = $CheepCheep
onready var attack_area : Area2D = $CheepCheep/AttackArea
onready var player_detector : Area2D = $CheepCheep/PlayerDetector
onready var player_exit_detector : Area2D = $CheepCheep/PlayerExitDetector
onready var platform_detector : Area2D = $CheepCheep/PlatformDetector
onready var particles : Particles2D = $CheepCheep/Poof
onready var stomp_sound : AudioStreamPlayer = $CheepCheep/Stomp
onready var poof_sound : AudioStreamPlayer = $CheepCheep/Disappear
onready var hit_sound : AudioStreamPlayer = $CheepCheep/Hit
onready var anim_player : AnimationPlayer = $CheepCheep/AnimationPlayer
onready var bottom_pos : Node2D = $CheepCheep/BottomPos
onready var water_detector : Node2D = $CheepCheep/WaterDetector

onready var visibility_enabler : VisibilityEnabler2D = $VisibilityEnabler2D
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
var idle_swim_speed := 25
var swim_speed := 50
var shell_max_speed := 560
var accel := 5

var facing_direction := -1
var time_alive := 0.0
var time_until_die := 0.0
var time_until_turn := 3.0

var color := Color(1, 0, 0)
var rainbow := false

var hit := false
var snap := Vector2(0, 12)

var bounced := false

var loaded := true

var character : Character

export var top_point : Vector2

func _set_properties():
	savable_properties = ["color", "rainbow"]
	editable_properties = ["color", "rainbow"]
	
func _set_property_values():
	set_property("color", color, true)
	set_property("rainbow", rainbow, true)


func detect_player(body : Character) -> void:
	if character == null and enabled and body != null and !dead:
		character = body

func remove_player(body : Character) -> void:
	if character == body:
		character = null

func on_visibility_changed(is_visible: bool) -> void:
	pass

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
	player_exit_detector.connect("body_exited", self, "remove_player")
	player_detector.scale = Vector2(1, 1) / scale
	player_exit_detector.scale = Vector2(1, 1) / scale
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
			if !rainbow:
				hit = true
				kinematic_body.set_collision_layer_bit(2, false)
				attack_area.set_collision_layer_bit(2, false)
				kinematic_body.set_collision_mask_bit(2, false)
				attack_area.set_collision_mask_bit(2, false)
				sprite.animation = "default"
				hit_sound.play()
				sprite.playing = false
				var normal := kinematic_body.global_position - hit_pos
				velocity = Vector2(sign(normal.x) * 225, (-225 if water_detector.get_overlapping_areas().size() <= 0 else sign(normal.y) * 50))
				position.y -= 2
				snap = Vector2(0, 0)
				time_until_die = 0.5
			else:
				hit_sound.play()
				var normal := kinematic_body.global_position - hit_pos
				velocity = Vector2(sign(normal.x) * 225, (-225 if water_detector.get_overlapping_areas().size() <= 0 else sign(normal.y) * 50))
				position.y -= 2

func _process(_delta) -> void:
	if mode == 1:
		# warning-ignore: integer_division
		sprite.frame = wrapi(OS.get_ticks_msec() / 166, 0, 4)
	if is_instance_valid(kinematic_body):
		if rainbow:
			color.h = float(wrapi(OS.get_ticks_msec(), 0, 500)) / 500
		
		sprite.playing = true
		color_sprite.frame = sprite.frame
		color_sprite.rotation = sprite.rotation
		color_sprite.position = sprite.position
		color_sprite.scale = sprite.scale
		color_sprite.flip_h = sprite.flip_h
		color_sprite.modulate = color

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
		
		if is_instance_valid(kinematic_body):
			visibility_enabler.global_position = kinematic_body.global_position
			if !hit:
				physics_process_normal(delta, is_in_platform)
			else:
				physics_process_hit(delta, is_in_platform)

func physics_process_normal(delta: float, is_in_platform: bool) -> void:
	if water_detector.get_overlapping_areas().size() > 0:
		if gravity_scale == 1:
			velocity.y = 120
		
		gravity_scale = 0
		
		if is_instance_valid(character):
			facing_direction = -1
			sprite.rotation = lerp_angle(sprite.rotation, character.global_position.angle_to_point(kinematic_body.global_position), delta * 2)
			velocity = velocity.move_toward(Vector2.RIGHT.rotated(sprite.rotation) * swim_speed, delta * 480)
		else:
			time_until_turn -= delta
			if time_until_turn <= 0:
				time_until_turn = 3.0
				facing_direction = -facing_direction
			
			sprite.rotation = lerp_angle(sprite.rotation, 0, delta * 2)
			velocity = velocity.move_toward(Vector2(-facing_direction * idle_swim_speed, 0), delta * 480)
	else:
		gravity_scale = 1
	
		if kinematic_body.is_on_floor():
			# the only enemy code that uses randomness
			facing_direction = randi() % 2
			if facing_direction == 0:
				facing_direction = -1
			velocity.x = -((randi() % 25) + 50) * facing_direction
			velocity.y = -((randi() % 50) + 200)
		
		# Ground collision
		if kinematic_body.is_on_floor():
			snap = Vector2(0, 0 if is_in_platform else 12)
		else: # or not
			snap = Vector2(0, 0)
		# Run physics
		velocity.y += gravity * gravity_scale
		
	sprite.flip_h = true if facing_direction == 1 else false	
	velocity = kinematic_body.move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
		
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
			
	if !dead:
		if water_detector.get_overlapping_areas().size() > 0:
			gravity_scale = 0
			velocity = velocity.move_toward(Vector2.ZERO, delta * 240)
		else:
			gravity_scale = 1

		# The cheep cheep is rolling around (from spin or ground pound)
		sprite.rotation_degrees += (velocity.x / (15 if gravity_scale == 1 else 5))
		
		if time_until_die > 0:
			time_until_die -= delta
			if time_until_die <= 0:
				time_until_die = 0

		if time_until_die <= 0:
			dead = true
			hide_timer = 0.45
			velocity.x = 0
			sprite.rotation_degrees = 0
			anim_player.play("Stomped")
	
	if sprite.visible:
		# Ground collision
		if kinematic_body.is_on_floor():
			snap = Vector2(0, 0 if is_in_platform else 12)
		else: # or not
			snap = Vector2(0, 0)
		
		# Run physics
		velocity.y += gravity * gravity_scale
		#kinematic_body.get_floor_normal()
		velocity = kinematic_body.move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
