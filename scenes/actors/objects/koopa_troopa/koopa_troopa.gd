extends GameObject

const rainbow_animation_speed := 500

onready var sprite : AnimatedSprite = $Koopa/Sprite
onready var sprite_color : AnimatedSprite = $Koopa/Sprite/Color
onready var attack_area : Area2D = $Koopa/AttackArea
onready var stomp_area : Area2D = $Koopa/StompArea
onready var water_detector : Area2D = $Koopa/WaterDetector
onready var left_check : RayCast2D = $Koopa/Left
onready var right_check : RayCast2D = $Koopa/Right
onready var koopa_sound = $Koopa/AudioStreamPlayer
onready var bottom_pos : Node2D = $Koopa/BottomPos
onready var visibility_notifier : VisibilityNotifier2D = $Koopa/VisibilityNotifier2D

onready var visibility_enabler : VisibilityEnabler2D = $VisibilityEnabler2D

onready var body : KinematicBody2D = $Koopa

func body_exists(): # Might as well be body.exists()
	return is_instance_valid(body) and !body.is_queued_for_deletion()

export var normal_sprite : SpriteFrames
export var normal_color_sprite : SpriteFrames
export var para_sprite : SpriteFrames
export var para_color_sprite : SpriteFrames
export var shell_scene : PackedScene

var dead = false
var loaded = false

var gravity : float
var gravity_scale : float
var velocity := Vector2()
var original_position

var delete_timer = 0.0
var speed = 30
var shell_max_speed = 560
var accel = 15

var facing_direction := -1
var time_alive = 0.0

var hit = false
var snap := Vector2(0, 12)

var shell
var shell_sprite
var shell_sprite_color
var shell_attack_area
var shell_stomp_area
var shell_destroy_area
var shell_grounded_check
var shell_in_can_collect_coins := false

const PARA_SIN_SPEED = 5.5
const PARA_SIN_AMOUNT = 3

var color := Color(0, 1, 0)
var rainbow := false
var winged := false
var shelled := false
var attack_cooldown := 0.0 # Prevents the player from getting hurt right after stomping on a paratroopa

func _set_properties():
	savable_properties = ["color", "rainbow", "winged", "shelled"]
	editable_properties = ["color", "rainbow", "shelled"]

func _set_property_values():
	set_property("color", color, true)
	set_property("rainbow", rainbow, true)
	set_property("winged", winged, true)

func on_visibility_changed(is_visible: bool) -> void:
	for raycast in [left_check, right_check]:
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
	original_position = global_position
	Singleton.CurrentLevelData.enemies_instanced += 1
	time_alive += float(Singleton.CurrentLevelData.enemies_instanced) / 2.0
	gravity = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.gravity
	
	var scene = get_tree().current_scene
	if scene.mode == 1 and scene.placed_item_property == "Para":
		set_property("winged", true)
	sprite.frames = para_sprite if winged else normal_sprite
	sprite_color.frames = para_color_sprite if winged else normal_color_sprite
	
	if scale.x < 0 and mode == 0 and enabled:
		facing_direction = sign(scale.x)
		scale.x = abs(scale.x)

func delete_wings():
	if !rainbow:
		winged = false
		sprite.frames = normal_sprite
		sprite_color.frames = normal_color_sprite

func retract_into_shell(invuln):
	if is_instance_valid(shell) or invuln:
		if invuln:
			koopa_sound.play()
		return
	
	shell = shell_scene.instance()
	shell_sprite = shell.get_node("Sprite")
	shell_sprite_color = shell_sprite.get_node("Color")
	shell_stomp_area = shell.get_node("StompArea")
	shell_destroy_area = shell.get_node("DestroyArea")
	shell_attack_area = shell.get_node("AttackArea")
	shell_grounded_check = shell.get_node("GroundedCheck")
	koopa_sound = shell.get_node("AudioStreamPlayer")
	koopa_sound.play()
	visibility_notifier = shell.get_node("VisibilityNotifier2D")
	add_child(shell)
	shell.global_position = body.global_position
	shell.reset_physics_interpolation()
	velocity = Vector2()
	snap = Vector2(0, 6)
	delete_wings()

func shell_hit(shell_pos : Vector2):
	if body_exists():
		kill(shell_pos)

func exploded(explosion_pos : Vector2):
	kill(explosion_pos)

func steely_hit(hit_pos : Vector2):
	kill(hit_pos)

func kill(hit_pos : Vector2):
	if !hit:
		if body_exists():
			retract_into_shell(rainbow)
		if is_instance_valid(shell):
			hit = true
			shell.set_collision_layer_bit(2, false)
			shell.set_collision_mask_bit(2, false)
			var normal = sign((shell.global_position - hit_pos).x)
			velocity.x = normal * 220
			velocity.y = -220
			z_index = 10
			shell_sprite.playing = false


func _process(_delta):
	if rainbow:
		# Hue rotation
		color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	if is_instance_valid(shell):
		# Sync color sprite
		shell_sprite_color.flip_h = shell_sprite.flip_h
		shell_sprite_color.frame = shell_sprite.frame
		shell_sprite_color.modulate = color
		
		# Toggle whether or not coins search for this shell
		var on_screen = visibility_notifier.is_on_screen()
		if shell_in_can_collect_coins != on_screen:
			var can_collect_coins = get_tree().current_scene.can_collect_coins
			if on_screen:
				can_collect_coins.append(shell)
			else:
				can_collect_coins.erase(shell)
			shell_in_can_collect_coins = on_screen
		
	elif body_exists():
		# Sync color sprite
		sprite_color.flip_h = sprite.flip_h
		sprite_color.animation = sprite.animation
		sprite_color.frame = sprite.frame
		sprite_color.modulate = color

func _physics_process(delta):
	if is_queued_for_deletion():
		print("this has been hit??")
		return # Prevent crashes
	
	time_alive += delta
	
	if !loaded and visibility_notifier and visibility_notifier.is_on_screen():
		loaded = true
	if mode != 1 and enabled and !dead and loaded:
		var level_bounds = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds
		if !hit:
			# Run the appropriate physics process function
			if is_instance_valid(shell):
				visibility_enabler.global_position = shell.global_position
				physics_process_shell(delta, level_bounds)
			elif body_exists():
				visibility_enabler.global_position = body.global_position
				physics_process_koopa(delta, level_bounds)
		elif !is_instance_valid(shell):
			# This shouldn't happen, but just in case
			hit = false
		else:
			# The shell is in the "hit" state where it falls off the screen
			visibility_enabler.global_position = shell.global_position
			shell_sprite.rotation_degrees += 2
			velocity.y += gravity
			shell.position += velocity * delta
			reset_physics_interpolation()
		if shelled == true :
			retract_into_shell(false)
		
		# Delete Koopa if the shell exists already
		if is_instance_valid(shell) and body_exists():
			body.queue_free()
			body = null

func physics_process_shell(delta, _level_bounds):
	# Check the attack hitbox
	for hit_body in shell_attack_area.get_overlapping_bodies():
		if hit_body.name.begins_with("Character"):
			var hit_speed = shell_max_speed
			velocity.x = (shell.global_position - hit_body.global_position).normalized().x
			if hit_body.attacking or hit_body.invincible:
				velocity.x *= shell_max_speed
				velocity.y = -275
			else:
				velocity.x *= hit_speed
			koopa_sound.play()
			
		if hit_body.name.begins_with("Rex"):
			velocity = Vector2(-velocity.x/2, -50)
	
	for hit_area in shell_attack_area.get_overlapping_areas():
		if hit_area.has_method("is_hurt_area"):
			velocity.x = (shell.global_position - hit_area.global_position).normalized().x
			velocity.x *= shell_max_speed
			velocity.y = -275
			koopa_sound.play()
	
	# The shell attacks this time
	for hit_area in shell_destroy_area.get_overlapping_areas():
		var hit_parent = hit_area.get_parent()
		var hit_parent_parent = hit_parent.get_parent()
		
		if hit_area.get_collision_layer_bit(2) == true and hit_parent_parent.has_method("shell_hit") and hit_parent_parent != self and abs(velocity.x) > 15:
			hit_parent_parent.shell_hit(shell.global_position)
			if hit_parent_parent.name.begins_with("Rex"):
				velocity = Vector2(-velocity.x/2, -50)
		
		elif hit_area.get_parent().has_method("is_coin"):
			hit_parent.shell_hit()
	
	# Check the stomp hitbox
	for hit_body in shell_stomp_area.get_overlapping_bodies():
		if hit_body.name.begins_with("Character"):
			if hit_body.velocity.y > 0 and !hit_body.swimming:
				if !hit_body.big_attack:
					if hit_body.state != hit_body.get_state_node("DiveState"):
						hit_body.set_state_by_name("BounceState", 0)
					hit_body.velocity.y = -330
					velocity.x = (shell.global_position - hit_body.global_position).normalized().x * shell_max_speed
					koopa_sound.play()
				else:
					shell_hit(hit_body.global_position)
	
	# Bounce off of walls
	if shell.test_move(shell.global_transform, Vector2(velocity.x * delta, 0)):
		velocity.x = -velocity.x
	
	shell.set_collision_layer_bit(2, abs(velocity.x) <= 15)
	
	# Sliding on the ground
	if shell_grounded_check.is_colliding():
		var check = shell_grounded_check
		if check.get_collision_normal().y == -1:
			velocity.x = lerp(velocity.x, 0, fps_util.PHYSICS_DELTA / 2.5)
		else:
			var normal = sign(check.get_collision_normal().x)
			velocity.x = lerp(velocity.x, 275 * normal, fps_util.PHYSICS_DELTA)
	
	# Sprite handling & physics
	shell_sprite.speed_scale = abs(velocity.x) / shell_max_speed
	shell_sprite.flip_h = velocity.x < 0
	if shell.get_node("WaterDetector").get_overlapping_areas().size() > 0:
		gravity_scale = 0.3
	else:
		gravity_scale = 1
	velocity.y += gravity * gravity_scale
	velocity.y += gravity * gravity_scale
	velocity = shell.move_and_slide_with_snap(velocity, snap, Vector2.UP.normalized(), true, 4, deg2rad(46))

func physics_process_koopa(delta, level_bounds):
	# Check the stomp hitbox first (to prevent overlaps from causing issues)
	for hit_body in stomp_area.get_overlapping_bodies():
		if hit_body.name.begins_with("Character"):
			if hit_body.velocity.y > 0 and !hit_body.swimming:
				if !hit_body.big_attack:
					if hit_body.state != hit_body.get_state_node("DiveState"):
						hit_body.set_state_by_name("BounceState", 0)
					hit_body.velocity.y = -330
					if winged:
						delete_wings()
						koopa_sound.play()
						attack_cooldown = 0.2 # Makes sure the player doesn't get hit right after
					elif !is_instance_valid(shell):
						retract_into_shell(rainbow)
				else:
					shell_hit(hit_body.global_position)
	
	# Then check the attack hitbox
	if attack_cooldown <= 0:
		for hit_body in attack_area.get_overlapping_bodies():
			if hit_body.name.begins_with("Character"):
				if (hit_body.attacking or hit_body.invincible) and !rainbow:
					retract_into_shell(rainbow)
					velocity.x = (shell.global_position - hit_body.global_position).normalized().x * (shell_max_speed)
					velocity.y = -275
				else:
					hit_body.damage_with_knockback(body.global_position)
		for hit_area in attack_area.get_overlapping_areas():
			if hit_area.has_method("is_hurt_area") and !rainbow:
				retract_into_shell(rainbow)
				velocity.x = (shell.global_position - hit_area.global_position).normalized().x * (shell_max_speed)
				velocity.y = -275
	else:
		attack_cooldown -= delta
	
	if !is_instance_valid(shell):
		sprite.flip_h = facing_direction == 1
		if !winged:
			# Walk and be affected by gravity
			sprite.animation = "walking"
			velocity.x = lerp(velocity.x, facing_direction * speed, fps_util.PHYSICS_DELTA * accel)
			if water_detector.get_overlapping_areas().size() > 0:
				gravity_scale = 0.3
			else:
				gravity_scale = 1
			velocity.y += gravity * gravity_scale
			velocity.y += gravity * gravity_scale
		else:
			# Paratroopas go up and down very slightly
			velocity = Vector2(0, 0)
			global_position.y = original_position.y + (sin(time_alive * PARA_SIN_SPEED) * PARA_SIN_AMOUNT)
			reset_physics_interpolation()
		
		velocity = body.move_and_slide_with_snap(velocity, snap, Vector2.UP.normalized(), true, 4, deg2rad(46))
		
		if !winged:
			# Collision with walls
			if !left_check.is_colliding() or (body.global_position.x < (level_bounds.position.x * 32) + 4) or body.test_move(body.global_transform, Vector2(-0.1, 0)):
				facing_direction = 1
			
			if !right_check.is_colliding() or (body.global_position.x > (level_bounds.end.x * 32 - 1) - 4) or body.test_move(body.global_transform, Vector2(0.1, 0)):
				facing_direction = -1
			
