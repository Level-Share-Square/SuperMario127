extends KinematicBody2D

class_name Character

signal state_changed
signal health_changed(new_health, new_shards)
signal nozzle_changed(new_nozzle)

signal fludd_activated
signal fludd_deactivated

signal start_moving
signal stop_moving

# Child nodes
onready var states_node = $States
onready var nozzles_node = $Nozzles
onready var powerups_node = $Powerups
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var cloudcontain = $CloudContainer

onready var sprite : AnimatedSprite = $Sprite
onready var fludd_sprite : AnimatedSprite = $Sprite/Fludd
onready var wing_sprite : AnimatedSprite = $Sprite/Wings
onready var water_sprite : AnimatedSprite = $Sprite/Water
onready var water_sprite_2 : AnimatedSprite = $Sprite/Water2
onready var water_particles : Particles2D = $Sprite/Particles2D
onready var water_particles_2 : Particles2D = $Sprite/Particles2DBack
onready var bubble_particles_left : Particles2D = $Sprite/BubblesLeft
onready var bubble_particles_right : Particles2D = $Sprite/BubblesRight
onready var turbo_particles : Particles2D = $Sprite/TurboParticles
onready var rocket_particles : Particles2D = $Sprite/RocketParticles

onready var collision_shape : CollisionShape2D = $Collision
onready var dive_collision_shape : CollisionShape2D = $CollisionDive
onready var collision_raycast : CollisionShape2D = $GroundCollision
onready var ground_shape : CollisionPolygon2D = $GroundShape
onready var left_collision : CollisionShape2D = $LeftCollision
onready var right_collision : CollisionShape2D = $RightCollision
onready var ground_collision_dive : CollisionShape2D = $GroundCollisionDive
onready var ground_check : RayCast2D = $GroundCheck
onready var water_check : RayCast2D = $WaterGroundCheck
onready var ground_check_dive : RayCast2D = $GroundCheckDive
onready var left_check : RayCast2D = $LeftCheck
onready var right_check : RayCast2D = $RightCheck
onready var slope_stop_check : RayCast2D = $SlopeStopCheck
onready var player_collision : Area2D = $PlayerCollision
onready var water_detector : Area2D = $WaterDetector
onready var lava_detector : Area2D = $LavaDetector
onready var liquid_detector : Area2D = $LiquidDetector
onready var pipe_detector : Area2D = $PipeDetector
onready var p_block_detector : Area2D = $PBlockDetector
onready var burn_particles : Particles2D = $BurnParticles
onready var terrain_detector : Area2D = $TerrainDetector
onready var platform_detector : Area2D = $PlatformDetector
onready var spin_area : Area2D = $SpinArea
onready var spin_swim_area : Area2D = $SpinSwimArea
onready var player_collision_shape : CollisionShape2D = $PlayerCollision/CollisionShape2D
onready var spin_area_shape : CollisionShape2D = $SpinArea/CollisionShape2D
onready var spin_swim_area_shape : CollisionShape2D = $SpinSwimArea/CollisionShape2D
onready var fludd_sound : AudioStreamPlayer = $FluddSound
onready var turbo_sound : AudioStreamPlayer = $TurboFluddSound
onready var fludd_boost_sound : AudioStreamPlayer = $FluddBoostSound
onready var fludd_charge_sound : AudioStreamPlayer = $FluddChargeSound
onready var nozzle_switch_sound : AudioStreamPlayer = $NozzleSwitchSound
onready var particles : Particles2D = $Particles2D
onready var slide_particles : Particles2D = $SlideParticles
onready var gp_particles1 : Particles2D = $GPParticles1
onready var gp_particles2 : Particles2D = $GPParticles2
onready var regen_particles : Particles2D = $RegenParticles
onready var rainbow_particles : Particles2D = $RainbowSparkles
onready var metal_particles : Particles2D = $MetalSparkles
onready var vanish_particles : Particles2D = $VanishSparkles
onready var quicksand_particles : Particles2D = $QuicksandParticles
onready var quicksand_particles2 : Particles2D = $QuicksandParticles2
onready var bottom_pos : Node2D = $BottomPos
onready var dialogue_focus : Node2D = $DialogueFocus
onready var ring_particles : AnimatedSprite = $RingParticles
onready var ring_particles_back : AnimatedSprite = $RingParticlesBack
onready var collected_shine : AnimatedSprite = $CollectedShine # used for the shine dance animation, can be edited to reflect different shine colours or sprites or something
onready var collected_shine_outline : AnimatedSprite = $CollectedShineOutline # this is separate from the recolorable part
onready var collected_shine_particles : Particles2D = $CollectedShine/ShineParticles # same as above
onready var death_sprite : AnimatedSprite = $DeathSprite
onready var death_fludd_sprite : AnimatedSprite = $DeathSprite/Fludd
onready var vanish_detector : Area2D = $VanishDetector
onready var raycasts = [ground_check, ground_check_dive, left_check, right_check, slope_stop_check]
onready var heal_timer = $HealTimer
onready var heal_tick_timer = $HealTickTimer
onready var ground_collider_enable_timer = $GroundColliderEnableTimer
export var bottom_pos_offset : Vector2
export var bottom_pos_dive_offset : Vector2
onready var squish_vertical_check = $SquishCasts/VerticalCheck
onready var squish_vertical_check_dive = $SquishCasts/VerticalCheckDive
onready var squish_left_check = $SquishCasts/LeftCheck
onready var squish_right_check = $SquishCasts/RightCheck


onready var spotlight : Light2D = $Spotlight

# Cutout
export var cutout_death : StreamTexture
export var cutout_circle : StreamTexture
export var cutout_shine : StreamTexture
var force_warp_fadeout : bool = false

# Basic Physics
export var initial_position := Vector2(0, 0)
export var velocity := Vector2(0, 0)
var last_velocity := Vector2(0, 0)
var last_position := Vector2(0, 0)
var in_wind := false
var extra_forces : Dictionary = {}


export var gravity_scale := 1.0
export var facing_direction := 1
export var move_direction := 0
export var last_move_direction := 0

export var move_speed := 216.0
export var acceleration := 16.0
export var deceleration := 30.0
export var aerial_acceleration := 16.0
export var friction := 27.0
export var aerial_friction := 2.3
export var max_aerial_velocity := 640
export var max_frictionless_slide_velocity : float = 450
export var raycast_length := 26

# Sounds
var sound_player
var footstep_interval := 0.0

# Extra
export var is_wj_chained := false
export var real_friction := 0.0
export var current_jump := 0
export var jump_animation := 0
export var direction_on_stick := 1
export var rotating := true
export var swimming := false
export var spawn_pos := Vector2(0, 0)
export var gravity : float

export var disable_movement := false
export var disable_turning := false
export var disable_friction := false
export var disable_animation := false

export var attacking := false
export var big_attack := false
export var invincible := false
export var heavy := false
export var shine_kill := false

export var player_id := 0

# States. Couldn't set static type due to circle reference
var switched = false
var state : Node = null
var last_state : Node = null
var switching_state := false
export var controllable := true
export var auto_flip := true
export var invulnerable := false
export var invulnerable_frames := 0
export var movable := true
export var dead := false
export var stomping := false
export var dive_cooldown := 0.0

export var health := 8
export var health_shards := 0
var nozzle : Node = null # Couldn't set static type due to circle reference
var using_turbo := false
var turbo_nerf := false

var fuel := 100.0
var stamina := 100.0
var breath := 100.0
var nozzles_list_index := 0
var powerup : Node = null # Couldn't set static type due to circle reference
var rainbow_stored := false
var next_flash := 0.0
var frames_until_flash := 3
var metal_voice := false
var file = File.new()
var ghost_pos = []
var ghost_anim = []
var temp_gp = []
var temp_ga = []
var temp_gsr = []
var temp_gar = []

var can_heal : bool = true
var healing_timer_enabled := false
var overheal_enabled := false

# Collision vars
var collision_down
var collision_up
var collision_left
var collision_right
var collided_last_frame := false
var using_dive_collision := false


export var snap := Vector2(0, 32)

export(Array, NodePath) var collision_exceptions = []

# Character vars
export var character := 0

export var mario_frames : SpriteFrames
export var luigi_frames : SpriteFrames

export var mario_alt_frames : SpriteFrames
export var luigi_alt_frames : SpriteFrames

export var mario_wing_frames : SpriteFrames
export var luigi_wing_frames : SpriteFrames

export var mario_collision : RectangleShape2D
export var mario_collision_offset : Vector2
export var mario_dive_collision : RectangleShape2D
export var mario_dive_collision_offset : Vector2

export var luigi_collision : RectangleShape2D
export var luigi_collision_offset : Vector2
export var luigi_dive_collision : RectangleShape2D
export var luigi_dive_collision_offset : Vector2

export var luigi_accel : float
export var luigi_fric : float
export var luigi_speed : float

# Had to add move up and move down to the end due to hardcoded input indices
enum input_names {left, right, jump, dive, spin, gp, gpcancel, fludd, nozzles, crouch, interact, up, down }

# Inputs 
# First parameter is "pressed",
# second parameter is "just_pressed", 
# and third parameter is the input name.
export var inputs : Array
export var controlled_locally = true
export var rotating_jump = false

var level_bounds = Rect2(0, 0, 80, 30)
var number_of_players = 2

var next_position : Vector2
var sync_interpolation_speed = 20
export var rotation_interpolation_speed = 15

var camera : Camera2D

#rpc_unreliable("update_inputs", 
#left, left_just_pressed,
#right, right_just_pressed,
#jump, jump_just_pressed,
#dive, dive_just_pressed,
#spin, spin_just_pressed
#)

const ANIM_IDS : Dictionary = {
	"armsOut" : 1,
	"bonkedLeft" : 2,
	"bonkedRight" : 3,
	"death" : 4,
	"deathFall" : 5,
	"diveLeft" : 6,
	"diveRight" : 7,
	"doubleFallLeft" : 8,
	"doubleFallRight" : 9,
	"doubleJumpLeft" : 10,
	"doubleJumpRight" : 11,
	"enterDoorLeft" : 12,
	"enterDoorRight" : 13,
	"exitDoorLeft" : 14,
	"exitDoorRight" : 15,
	"fallLeft" : 16,
	"fallRight" : 17,
	"flyLeft" : 18,
	"flyRight" : 19,
	"groundPoundEndLeft" : 20,
	"groundPoundEndRight" : 21,
	"groundPoundLeft" : 22,
	"groundPoundRight" : 23,
	"idleLeft" : 24,
	"idleRight" : 25,
	"jumpLeft" : 26,
	"jumpRight" : 27,
	"lavaBoost" : 28,
	"movingIn" : 29,
	"movingLeft" : 30,
	"movingOut" : 31,
	"movingRight" : 32,
	"pipeExitLeft" : 33,
	"pipeExitRight" : 34,
	"pipeLeft" : 35,
	"pipeRight" : 36,
	"shineDance" : 37,
	"shineFall" : 38,
	"spinning" : 39,
	"starRunLeft" : 40,
	"starRunRight" : 41,
	"swimming" : 42,
	"tripleJumpLeft" : 43,
	"tripleJumpRight" : 44,
	"wallSlideLeft" : 45,
	"wallSlideRight" : 46,
	"talking" : 47,
	"happy" : 48,
	"shocked" : 49,
	"nodding" : 50,
	"disagree": 51,
	"thinking": 52,
	"angry": 53,
}

func _ready():
	Singleton.CurrentLevelData.can_pause = true

	heal_timer.connect("timeout", self, "_on_heal_timer_timeout")
	heal_tick_timer.connect("timeout", self, "_on_heal_tick_timer_timeout")
	ground_collider_enable_timer.connect("timeout", self, "_on_ground_collder_timer_timeout")
	print(Singleton.CurrentLevelData.level_data.vars.transition_data)
	if Singleton.CurrentLevelData.level_data.vars.transition_data != []:
		hide()
		toggle_movement(false)
	else:
		show()
		toggle_movement(true)
	Singleton.Music.toggle_underwater_music(false)
	for input in input_names.keys():
		inputs.append([false, false, str(input)])


#slavery in super mario 127 :flushed:
puppet func sync(pos, vel, sprite_frame, sprite_animation, sprite_rotation, is_attacking, is_big_attacking, is_heavy, is_dead, is_controllable): # Ok slave
	next_position = pos
	velocity = vel
	sprite.animation = sprite_animation
	sprite.frame = sprite_frame
	sprite.rotation_degrees = sprite_rotation
	attacking = is_attacking
	big_attack = is_big_attacking
	heavy = is_heavy
	dead = is_dead
	controllable = is_controllable
		
func exploded(explosion_pos : Vector2) -> void:
	if !invincible:
		damage_with_knockback(explosion_pos, 2)

func steely_hit(steely_pos : Vector2) -> void:
	if !invincible:
		damage_with_knockback(steely_pos, 2)

func damage_with_knockback(hit_pos : Vector2, amount : int = 1, cause : String = "hit", frames : int = 180) -> void:
	if !invulnerable:
		# Mario shouldn't take damage with the vanish cap*
		if amount > 0 and is_instance_valid(powerup) and powerup.get_name() == "VanishPowerup":
			return
		knockback(hit_pos)
		damage(amount, cause, frames)

func knockback(hit_pos: Vector2):
	if is_instance_valid(state) and state.disable_knockback: return
	
	var direction := sign((global_position - hit_pos).normalized().x)
	velocity.x = direction * 235
	velocity.y = -225
	set_state_by_name("KnockbackState", 0)
	

# warning-ignore: unused_argument
func load_in(level_data : LevelData, level_area : LevelArea):
	level_bounds = level_area.settings.bounds
	for exception in collision_exceptions:
		add_collision_exception_with(get_node(exception))
	var _connect = player_collision.connect("body_entered", self, "player_hit")
	
	# Whether or not the alt character (e.g. Wario for Mario) should be loaded instead
	var use_alt_character : bool = Singleton.PlayerSettings.player1_character == Singleton.PlayerSettings.player2_character and player_id != 0
	match character:
		0: # Mario
			sound_player = $Sounds
			$Sounds2.queue_free()
			remove_child($Sounds2)
			sprite.frames = mario_alt_frames if use_alt_character else mario_frames
			real_friction = friction
		1: # Luigi
			sound_player = $Sounds2
			$Sounds.queue_free()
			remove_child($Sounds)
			sprite.frames = luigi_alt_frames if use_alt_character else luigi_frames
			move_speed = luigi_speed
			acceleration = luigi_accel
			friction = luigi_fric
			real_friction = luigi_fric
			wing_sprite.frames = luigi_wing_frames
		_:
			printerr("Illegal character loaded: " + str(character) + " REEEEEE")
	
	sound_player.set_deferred("name", "Sounds")
	call_deferred("add_child", sound_player) #Will throw an error if the level you're in is reset. Not that big of a deal.
	# Death sprites are shared
	death_sprite.frames = sprite.frames

	collision_shape.disabled = false
	collision_raycast.disabled = false
	left_collision.disabled = false
	right_collision.disabled = false
	gravity = level_area.settings.gravity
	
	# reset some stuff that can be changed by accident when using the editor
	sprite.playing = true
	collected_shine.visible = false
	collected_shine.get_node("ShineParticles").emitting = false
	
	#print(Singleton.CheckpointSaved.current_checkpoint_id)
	if Singleton.CheckpointSaved.current_checkpoint_id != -1 and Singleton.CurrentLevelData.level_data.vars.transition_data == []:
		position = Singleton.CheckpointSaved.current_spawn_pos
		reset_physics_interpolation()
		var score_from_before = Singleton.CurrentLevelData.time_score
		Singleton.CurrentLevelData.start_tracking_time_score()
		Singleton.CurrentLevelData.time_score = score_from_before
	else:
		# start speedrun timer
		if Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible and Singleton.CheckpointSaved.current_checkpoint_id == -1:
			if Singleton.CurrentLevelData.level_data.vars.transition_data == []:
				Singleton.CurrentLevelData.start_tracking_time_score()
			else:
				var score_from_before = Singleton.CurrentLevelData.time_score
				Singleton.CurrentLevelData.start_tracking_time_score()
				Singleton.CurrentLevelData.time_score = score_from_before
		elif Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible and Singleton.CurrentLevelData.level_data.vars.transition_data != []:
			var score_from_before = Singleton.CurrentLevelData.time_score
			Singleton.CurrentLevelData.start_tracking_time_score()
			Singleton.CurrentLevelData.time_score = score_from_before

var prev_is_grounded := false
func is_grounded() -> bool:
	# "Death barrier", can only be reached by collecting a shine sprite
	if position.y > (level_bounds.end.y * 32) + 256:
		return true
	
	var raycast_node := ground_check
	raycast_node.cast_to = Vector2(0, raycast_length) #26 or 30
	if !ground_collision_dive.disabled:
		raycast_node = ground_check_dive
		raycast_node.cast_to = Vector2(0, 7.5)
	
	var normal = Vector2.UP
	if raycast_node.is_colliding():
		normal = raycast_node.get_collision_normal()
	
	var is_downward: bool = velocity.y > -1
	var new_is_grounded := (raycast_node.is_colliding() or water_check.is_colliding() or is_on_floor()) and is_downward
	
	prev_is_grounded = new_is_grounded
	return prev_is_grounded

func is_ceiling() -> bool:
	return test_move(self.transform, Vector2(0, -0.1)) and collided_last_frame

func is_walled() -> bool:
	return (is_walled_left() or is_walled_right()) and collided_last_frame

func is_walled_left() -> bool:
	return test_move(self.transform, Vector2(-0.5, 1)) and test_move(self.transform, Vector2(-0.5, -1)) and collided_last_frame

func is_walled_right() -> bool:
	return test_move(self.transform, Vector2(0.5, 1)) and test_move(self.transform, Vector2(0.5, -1)) and collided_last_frame

func will_collide(multiplier: float = 1) -> bool:
	return test_move(self.transform, velocity * multiplier * fps_util.PHYSICS_DELTA)

func hide() -> void:
	visible = false
	velocity = Vector2(0, 0)
	position = initial_position
	reset_physics_interpolation()

func show() -> void:
	visible = true

# new_state is of type State, however adding static typing would cause a cyclic dependency
func set_state(new_state: Node, delta: float) -> void:
	if(is_instance_valid(state)):
		if(state.name=="LaunchStarState"):
			return
	last_state = state
	state = null
	if is_instance_valid(last_state):
		last_state._stop(delta)
	if is_instance_valid(new_state):
		state = new_state
		new_state._start(delta)
	emit_signal("state_changed", new_state, last_state)

func get_state_node(name: String) -> Node:
	if states_node.has_node(name):
		return states_node.get_node(name)
	return null

func get_powerup_node(name: String) -> Node:
	if powerups_node.has_node(name):
		return powerups_node.get_node(name)
	return null

func set_powerup(powerup_node: Node, set_temporary_music: bool, duration = -1) -> void:
	if is_instance_valid(powerup):
		# Prevent switching away from rainbow star
		if powerup.name == "RainbowPowerup" and powerup != powerup_node\
		and is_instance_valid(powerup_node): # unless it's running out
			return
		
		powerup.time_left = 0
		powerup._stop(0)
		powerup.remove_visuals()
	
	powerup = powerup_node
	if is_instance_valid(powerup):
		powerup.play_temp_music = set_temporary_music
		if duration != -1:
			powerup.time_left = duration
		powerup._start(0, set_temporary_music)
		powerup.apply_visuals()

func set_state_by_name(name: String, delta: float = 0.0001) -> void:
	if is_instance_valid(get_state_node(name)):
		set_state(get_state_node(name), delta)
		
func add_nozzle(new_nozzle: String) -> void:
	if !new_nozzle in Singleton.CurrentLevelData.level_data.vars.nozzles_collected:
		Singleton.CurrentLevelData.level_data.vars.nozzles_collected.append(new_nozzle)

func get_nozzle_node(name: String) -> Node:
	if nozzles_node.has_node(name):
		return nozzles_node.get_node(name)
	return null

# jank af, don't question it, just accept that it does its job
func nozzle_sort(a, b):
	if b != "null" and (a == "null" or a[0] < b[0]):
		return true
	return false

func set_nozzle(new_nozzle: String, change_index := true) -> void:
	Singleton.CurrentLevelData.level_data.vars.nozzles_collected.sort_custom(self, "nozzle_sort")
	
	fludd_sound.stop()
	turbo_sound.stop()
	fludd_charge_sound.stop()
	if is_instance_valid(nozzle):
		nozzle.activated = false
	nozzle = get_nozzle_node(str(new_nozzle))
	water_sprite.animation = "in"
	water_sprite.frame = 6
	water_sprite.rotation_degrees = 0
	using_turbo = false
	turbo_nerf = false
	if change_index:
		nozzles_list_index = Singleton.CurrentLevelData.level_data.vars.nozzles_collected.find(str(new_nozzle))
	
	if is_instance_valid(nozzle) and (is_instance_valid(powerup) and powerup.name == "RainbowPowerup"):
		set_nozzle("null", true) # Mario simply isn't allowed to have fludd
	else:
		emit_signal("nozzle_changed", new_nozzle)

# Handles getting hit by another player
func player_hit(body : Node) -> void:
	# for some reason it's possible for the player to be hit by themselves when fired out of a cannon 
	if body == self:
		return

	if body.name.begins_with("Character") and !big_attack:
		var mul_sign := sign(global_position.x - body.global_position.x)
		if !body.big_attack:
			if global_position.y + 8 < body.global_position.y:
				velocity.y = -230
				#body.stomped_sound_player.play() -Felt weird without animations
				if state != get_state_node("DiveState") and state != get_state_node("GroundPoundState") and state != get_state_node("GroundPoundStartState") and state != get_state_node("GroundPoundEndState"):
					set_state_by_name("BounceState", 0)
			elif global_position.y - 8 > body.global_position.y:
				velocity.y = 150
			else:
				body.velocity.x = -250 * mul_sign
				if body.attacking and !attacking:
					velocity.x = 205 * mul_sign
					velocity.y = -175
					set_state_by_name("KnockbackState", 0)
					sound_player.play_hit_sound()
				elif !attacking or (body.attacking and attacking):
					velocity.x = 250 * mul_sign
		else:
			velocity.x = 205 * mul_sign
			velocity.y = -175
			body.velocity.x = -250 * mul_sign
			set_state_by_name("KnockbackState", 0)
			sound_player.play_hit_sound()
			
func set_zoom_tween(target: Vector2, time : float):
	camera.set_zoom_tween(target, time)

func _process(delta: float) -> void:
	
	if fuel <= 0:
		fuel = 0
	
	if next_position:
		position = position.linear_interpolate(next_position, fps_util.PHYSICS_DELTA * sync_interpolation_speed)
		reset_physics_interpolation()

	collected_shine_outline.frame = collected_shine.frame
	collected_shine_outline.position = collected_shine.position
	collected_shine_outline.scale = collected_shine.scale
	collected_shine_outline.visible = collected_shine.visible
	collected_shine_outline.z_index = collected_shine.z_index
	collected_shine_outline.reset_physics_interpolation()
	
	if state and state.name == "NoActionState":
		return
	
	if is_instance_valid(powerup):
		if powerup.time_left <= 2.5:
			for overlap in vanish_detector.get_overlapping_bodies():
				if is_instance_valid(overlap) and powerup.time_left <= 1.0 and powerup.id == "Vanish":
					powerup.time_left = 1
			frames_until_flash -= 1
			if frames_until_flash <= 0:
				frames_until_flash = 3
				powerup.toggle_visuals()
	
	sprite.self_modulate.a8 = 100 if invulnerable_frames%2 == 1 else 255

func damage(amount : int = 1, cause : String = "hit", frames : int = 180) -> void:
	if !dead:
		if invincible:
			frames = 4
		else:
			health -= amount
			emit_signal("health_changed", health, health_shards)
		
		invulnerable = true if frames != 0 else false
		invulnerable_frames = frames
		if health <= 0:
			health = 0 # Fix -1 bug
			sound_player.play_last_hit_sound()
			kill(cause)
		else:
			if cause == "crushed":
				sound_player.play_last_hit_voice_sound()
			elif cause != "lava":
				sound_player.play_hit_sound()
				

func slow_heal(shards : int = 1, tick : float = 1, time : float = 1, can_overheal : bool = false) -> void:
	if can_heal:
		overheal_enabled = can_overheal
		healing_timer_enabled = true
		heal_tick_timer.wait_time = (tick / float(shards))
		heal_timer.wait_time = time
		heal_timer.start()
		heal_tick_timer.start()
		regen_particles.emitting = true
		heal(1)

func heal(shards : int = 1) -> void:
	if !dead and health != 8:
		health_shards += shards
		# warning-ignore: narrowing_conversion
		health = clamp(int(health + floor(health_shards / 5.0)), 0, 8)
		health_shards = health_shards % 5
		if health == 8:
			health_shards = 0
		
		emit_signal("health_changed", health, health_shards)


func get_weight() -> int:
	return 2 if metal_voice else 1

func _physics_process(delta: float) -> void:
	update_inputs()
	if state and (state.name == "NoActionState" or state.name == "LaunchStarState"):
		update_ghost()
		return
	
	bottom_pos.position = bottom_pos_offset if ground_collision_dive.disabled else bottom_pos_dive_offset
	bottom_pos.reset_physics_interpolation()
	var is_in_platform := false
	for body in platform_detector.get_overlapping_areas():
		if body.has_method("is_platform_area"):
			if body.is_platform_area():
				is_in_platform = true
			
			if body.get_parent() is PhysicsBody2D:
				if state == $States/SlideStopState or body.get_parent().can_collide_with(self):
					remove_collision_exception_with(body.get_parent())
					for raycast in raycasts:
						raycast.remove_exception(body.get_parent())
				else:
					add_collision_exception_with(body.get_parent())
					for raycast in raycasts:
						raycast.add_exception(body.get_parent())
	
	invulnerable = invulnerable_frames > 0
	if invulnerable_frames > 0:
		invulnerable_frames -= 1
	
	var is_in_water = water_detector.get_overlapping_areas().size() > 0
	if is_in_water and (max_aerial_velocity == 640 or gravity_scale == 1):
		gravity_scale = 0.5
		max_aerial_velocity = 320
	elif !is_in_water and (max_aerial_velocity == 320 or gravity_scale == 0.5):
		gravity_scale = 1
		max_aerial_velocity = 640
		
	if is_in_water:
		var fuel_increment = 0.15
		fuel = clamp(fuel + fuel_increment, 0, 100)
		if player_id == 0 and Singleton.Music.has_water and !Singleton.Music.play_water:
			Singleton.Music.toggle_underwater_music(true)
	else:
		breath = clamp(breath + 1, 0, 100)
		if player_id == 0 and Singleton.Music.play_water:
			Singleton.Music.toggle_underwater_music(false)
	
	# Gravity
	# Twice to work the same as 120fps
	velocity.y += gravity * gravity_scale
	velocity.y += gravity * gravity_scale
	if !swimming:
		velocity.y = clamp(velocity.y, velocity.y, max_aerial_velocity)
	
	if is_instance_valid(state):
		disable_movement = state.disable_movement or (nozzle != null and (nozzle.name == "TurboNozzle" and nozzle.activated))
		disable_turning = state.disable_turning or (nozzle != null and (nozzle.name == "TurboNozzle" and nozzle.activated))
		disable_animation = state.disable_animation
		if in_wind:
			disable_friction = true
		else:
			disable_friction = state.disable_friction or (nozzle != null and (nozzle.name == "TurboNozzle" and nozzle.activated))
	else:
		disable_movement = false
		disable_turning = false
		disable_animation = false
		if in_wind:
			disable_friction = true
		else:
			disable_friction = false
	
	# Movement
	move_direction = 0
	if inputs[0][0] and !inputs[1][0] and disable_movement == false:
		move_direction = -1
	elif inputs[1][0] and !inputs[0][0] and disable_movement == false:
		move_direction = 1
	else:
		move_direction = 0 #redundacy never hurt anyone :P
	
	if move_direction == 0 and disable_movement == false and nozzle != null and nozzle.name == "TurboNozzle" and nozzle.activated:
		move_direction = facing_direction
			
	if !controllable:
		if is_on_floor():
			velocity.y = 0 # so velocity doesn't become incredibly high when not controllable
	
	# Horizontal physics
	if move_direction != 0 and controllable:
		if is_grounded():
			# Accelerate/decelerate
			if velocity.x * move_direction < 0: #why. just why. you already have the move direction, dingus.
				velocity.x += deceleration * move_direction
			elif velocity.x * move_direction < move_speed:
				velocity.x += acceleration * move_direction
			elif velocity.x * move_direction > move_speed:
				velocity.x -= 3.5 * move_direction
			facing_direction = move_direction
		else:
			if velocity.x * move_direction < move_speed:
				velocity.x += aerial_acceleration * move_direction
			elif velocity.x * move_direction > move_speed:
				velocity.x -= 0.25 * move_direction
			if !disable_turning:
				facing_direction = move_direction
				pass
	elif !disable_friction:
		if abs(velocity.x) > 0:
			if abs(velocity.x) > 15:
				var new_velocity
				if is_on_floor():
#					new_velocity = 
#					if abs(new_velocity) > 0:
					velocity.x -= sign(velocity.x) * friction
#					else:
#						velocity.x -= sign(velocity.x) * clamp(abs(new_velocity), 0, velocity.x)
				else:
					new_velocity = sign(velocity.x) * aerial_friction * (2 if abs(velocity.x) > move_speed else 1)
#					if abs(new_velocity) > 0:
					velocity.x -= new_velocity
#					else:
#						velocity.x -= sign(velocity.x) * clamp(abs(new_velocity), 0, velocity.x)
			else:
				velocity.x = 0
	
	
	#frictionless is affected by gravity on slopes (also gets dives working with friction)
	if disable_friction and is_grounded() and !(nozzle != null and (nozzle.name == "TurboNozzle" and nozzle.activated)) and powerup != get_powerup_node("RainbowPowerup") and state != get_state_node("ButtSlideState"):
		var normal = ground_check.get_collision_normal()
		var max_speed = 450
		if state == null or state == get_state_node("DiveState"):
			max_speed = max_frictionless_slide_velocity
		elif state == get_state_node("ButtSlideState"):
			max_speed = state.move_speed
		
		if abs(velocity.length()) < max_speed and abs(normal.y) < 1:
			if normal.y > 0:
				if move_direction == -1:
					velocity.x += gravity*gravity_scale*normal.x*1.25
				elif move_direction == 1:
					velocity.x += gravity*gravity_scale*normal.x*5.5
				else:
					velocity.x += gravity*gravity_scale*normal.x*1.5

			if normal.y < 0:
				if move_direction == 1:
					velocity.x += gravity*gravity_scale*normal.x*1.25
				elif move_direction == -1:
					velocity.x += gravity*gravity_scale*normal.x*5.5
				else:
					velocity.x += gravity*gravity_scale*normal.x*1.5
	
	
	if is_grounded() and !disable_animation and movable and controlled_locally and controllable and abs(velocity.x) > 15:
		if !is_walled():
			sprite.speed_scale = abs(velocity.x) / move_speed if abs(velocity.x) > move_speed else 1.0
			sprite.animation = "movingRight" if facing_direction == 1 else "movingLeft"
		else:
			sprite.speed_scale = 0
			sprite.animation = "idleRight" if facing_direction == 1 else "idleLeft"
		if footstep_interval <= 0 and sprite.speed_scale > 0:
			sound_player.play_footsteps()
			footstep_interval = clamp(0.8 - (sprite.speed_scale / 2.5), 0.1, 1)
		footstep_interval -= delta
	elif is_grounded():
		if !disable_animation and movable and controlled_locally:
			sprite.speed_scale = 1
			sprite.animation = "idleRight" if facing_direction == 1 else "idleLeft"
	
	# Handle sprite offset
	if movable and (!is_instance_valid(state) or !state.override_rotation) and (!is_instance_valid(nozzle) or !nozzle.override_rotation) and !rotating_jump and last_state != get_state_node("SlideState"):
		var sprite_rotation = 0
		var sprite_offset = Vector2()
		if ground_check.is_colliding():
			var normal = ground_check.get_collision_normal()
			sprite_rotation = (atan2(normal.y, normal.x) + (PI/2)) / 2
			sprite_offset = Vector2(rad2deg(sprite_rotation) / 10, -abs(rad2deg(sprite_rotation) / 10))

			# Translate velocity X to Y
			if normal.y != 0: # Avoid division by zero (what)
				var add = (velocity.x * normal.x / normal.y) * -1
				if add < 0: # upwards velocity, don't allow that
					add = 0
				velocity.y += add
			
			if abs(sprite_rotation) >= 80:
				sprite_rotation = 0
			# this is required to keep mario from falling off slopes
			#velocity.y += (abs(sprite_rotation) + 1) * 100
			
			#if !abs(normal.x) > 0.2:
			#	velocity.y = 0
		
		sprite.position = sprite.position.linear_interpolate(sprite_offset, fps_util.PHYSICS_DELTA * rotation_interpolation_speed)
		sprite.rotation = lerp_angle(sprite.rotation, sprite_rotation, fps_util.PHYSICS_DELTA * rotation_interpolation_speed)
		sprite.rotation_degrees = wrapf(sprite.rotation_degrees, -180, 180)
		sprite.reset_physics_interpolation()
	
	# Update all states, nozzles and powerups
	if Singleton.PlayerSettings.other_player_id == -1 or Singleton.PlayerSettings.my_player_index == player_id:
		for state_node in states_node.get_children():
			state_node.handle_update(delta)
		for nozzle_node in nozzles_node.get_children():
			nozzle_node.handle_update(delta)
		for powerup_node in powerups_node.get_children():
			powerup_node.handle_update(delta)
		
		handle_liquids(liquid_detector.get_overlapping_areas(), delta)
	
	# Handle powerup
	if is_instance_valid(powerup):
		invincible = powerup.is_invincible
		powerup.time_left -= delta
		
		if powerup.time_left <= 0:
			powerup.time_left = 0
			set_powerup(null, true)
	else:
		invincible = false
	
	# Handle state
	if is_instance_valid(state):
		big_attack = state.attack_tier > 1
		attacking = state.attack_tier > 0
		
		if state.use_dive_collision != using_dive_collision:
			call_deferred("set_dive_collision", state.use_dive_collision)
		
		if auto_flip:
			if state.auto_flip == true:
				sprite.flip_h = false if facing_direction == 1 else true
			else:
				sprite.flip_h = false
	else:
		attacking = false
		big_attack = false
		if auto_flip:
			sprite.flip_h = false
	
	# Set up snap
	if is_instance_valid(state) and state.disable_snap:
		snap = Vector2()
	elif (left_check.is_colliding() or right_check.is_colliding()) and velocity.y > 0:
		var normal = ground_check.get_collision_normal()
		snap = Vector2(0, 6 if normal.x == 0 else 12)
	else:
		snap = Vector2()
	
	# Switch nozzle
	if (inputs[8][1] and Singleton.CurrentLevelData.level_data.vars.nozzles_collected.size() > 1
	# Rainbow Mario can't use fludd, so no point in allowing switching nozzles
	and (!is_instance_valid(powerup) or powerup.name != "RainbowPowerup")):
		nozzles_list_index += 1
		if nozzles_list_index >= Singleton.CurrentLevelData.level_data.vars.nozzles_collected.size():
			nozzles_list_index = 0
		
		var new_nozzle = str(Singleton.CurrentLevelData.level_data.vars.nozzles_collected[nozzles_list_index])
		set_nozzle(new_nozzle, false)
		
		nozzle_switch_sound.play()
		#print(Singleton.CurrentLevelData.level_data.vars.nozzles_collected)
	
	# Handle nozzle
	if is_instance_valid(nozzle):
		if nozzle.activated and nozzle.name == "TurboNozzle":
			attacking = true
		elif !(is_instance_valid(state) and state.attack_tier != 0):
			attacking = false
		fludd_sprite.visible = true
		water_sprite.visible = false
		if nozzle.get_name() == "HoverNozzle" and false:
			water_sprite_2.visible = true
			water_sprite_2.flip_h = water_sprite.flip_h
			water_sprite_2.animation = water_sprite.animation
			water_sprite_2.frame = water_sprite_2.frame
		else:
			water_sprite_2.visible = false
			
		if nozzle.get_name() != "TurboNozzle":
			turbo_particles.emitting = false
		
		if nozzle.get_name() != "RocketNozzle":
			rocket_particles.emitting = false
		
		# TODO: match... or array
		if character == 0:
			fludd_sprite.frames = nozzle.frames
			death_fludd_sprite.frames = fludd_sprite.frames
		else:
			fludd_sprite.frames = nozzle.frames_luigi
			death_fludd_sprite.frames = fludd_sprite.frames
		fludd_sprite.animation = sprite.animation
		fludd_sprite.frame = sprite.frame
		
		# TODO: match... or array
		if character == 0:
			if sprite.animation in nozzle.animation_water_positions:
				water_sprite.position = nozzle.animation_water_positions[sprite.animation]
			else:
				water_sprite.position = nozzle.fallback_water_pos_right if facing_direction == 1 else nozzle.fallback_water_pos_left
			water_sprite.reset_physics_interpolation()
		else:
			if sprite.animation in nozzle.animation_water_positions_luigi:
				water_sprite.position = nozzle.animation_water_positions_luigi[sprite.animation]
			else:
				water_sprite.position = nozzle.fallback_water_pos_right_luigi if facing_direction == 1 else nozzle.fallback_water_pos_left_luigi
			water_sprite.reset_physics_interpolation()
		
		water_sprite_2.position = water_sprite.position - Vector2(-5 * facing_direction, 2)
		water_sprite_2.reset_physics_interpolation()
		water_particles.position = water_sprite.position + Vector2(12, 3)
		water_particles.reset_physics_interpolation()
		water_particles_2.position = water_particles.position + (Vector2(9.5 * facing_direction, 2))
		water_particles_2.reset_physics_interpolation()
		turbo_particles.process_material.direction = Vector3(-facing_direction, 0, 0)
		turbo_particles.position = water_sprite.position + Vector2(-3 * facing_direction, -11.5 if facing_direction == -1 else 11.5)
		turbo_particles.reset_physics_interpolation()
		rocket_particles.position = water_sprite.position + Vector2(8 if facing_direction == 1 else 10, 1.5)
		rocket_particles.reset_physics_interpolation()
	else:
		fludd_sprite.visible = false
		water_sprite.visible = false
		water_sprite_2.visible = false
		turbo_particles.emitting = false
		rocket_particles.emitting = false
	
	death_fludd_sprite.visible = fludd_sprite.visible
	
	# Move by velocity
	if movable:

		velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, deg2rad(46))
		
		if (last_position != Vector2.ZERO and (last_position - global_position).length_squared() > 0
			and get_world_2d().direct_space_state.intersect_ray(last_position, global_position, [self], 1).size() > 0):
			position = last_position
			reset_physics_interpolation()
			
			if velocity.length_squared() < 1:
				# Clip attempt, just reset velocity
				velocity = last_velocity * 0.95
		else:
			var slide_count = get_slide_count()
			collided_last_frame = slide_count > 0
	else:
		collided_last_frame = false

	# Boundaries
	if position.y > (level_bounds.end.y * 32) + 128:
		if (Singleton.PlayerSettings.other_player_id == -1 or Singleton.PlayerSettings.my_player_index == player_id)\
		and controllable: # If not controllable, the player is (likely) collecting a shine
			kill("fall")
	if position.x < level_bounds.position.x * 32:
		position.x = level_bounds.position.x * 32
		velocity.x = 0
	if position.x > level_bounds.end.x * 32 -1:
		position.x = level_bounds.end.x * 32 -1
		velocity.x = 0
	
	last_position = global_position
	
	if velocity != Vector2.ZERO and last_velocity == Vector2.ZERO:
		emit_signal("start_moving")
	elif velocity == Vector2.ZERO and last_velocity != Vector2.ZERO:
		emit_signal("stop_moving")
	
	last_velocity = velocity
	last_move_direction = move_direction
	
	if get_tree().get_current_scene().switch_timer < 0.2 and get_tree().get_current_scene().switch_timer > 0:
		if p_block_detector.get_overlapping_areas().size() > 0:
			get_tree().get_current_scene().switch_timer = 0.2

	# Send network message (unused)
	if Singleton.PlayerSettings.other_player_id != -1:
		if player_id == Singleton.PlayerSettings.my_player_index and is_network_master():
			rpc_unreliable("sync", position, velocity, sprite.frame, sprite.animation, sprite.rotation_degrees, attacking, big_attack, heavy, dead, controllable)
			#print("hi")
	
	update_ghost()


func update_ghost():
	if !Singleton2.save_ghost:
		GhostArrays.temp_gp.append(Vector2(int(position.x), int(position.y)))
		GhostArrays.temp_ga.append(ANIM_IDS[sprite.animation])
		GhostArrays.temp_gsr.append(int(sprite.rotation_degrees))
		GhostArrays.temp_gar.append(Singleton.CurrentLevelData.area)
	
	var level_info = Singleton.CurrentLevelData.level_info
	if Singleton2.save_ghost == true and GhostArrays.dont_save == false:
		Singleton2.save_ghost = false
		
		var directory := Directory.new()
		if !directory.dir_exists("user://replays"):
			directory.make_dir("user://replays")
		
		file.open("user://replays/" + str(level_info.level_name) + "_" + str(level_info.selected_shine) + ".127ghost", File.WRITE)
		file.store_var(GhostArrays.temp_gp)
		file.store_var(GhostArrays.temp_ga)
		file.store_var(GhostArrays.temp_gsr)
		file.store_var(GhostArrays.temp_gar)
		file.close()

		
func encode_int_bytes(val: int, num: int) -> PoolByteArray:
	var output = PoolByteArray([])
	for i in range(num):
		var byte = (
		val >> (
			(
				num - i - 1
			) << 3
		) # cut off everything before this byte
		& 255 # cut off everything after this byte
	)
		output.append(byte)
	return output
	
func switch_areas(area_id, transition_time):
	Singleton.SceneTransitions.reload_scene(cutout_circle, cutout_circle, transition_time, area_id, false, false)
	if !switched:
		if Singleton.PlayerSettings.other_player_id != -1:
			get_tree().multiplayer.send_bytes(JSON.print(["area", area_id, transition_time]).to_ascii())
		switched = true

	
func kill(cause: String) -> void:
	Singleton.CurrentLevelData.can_pause = false
	if !dead:
		if Singleton.PlayerSettings.other_player_id != -1:
			get_tree().multiplayer.send_bytes(JSON.print(["reload"]).to_ascii())
		dead = true
		var reload := true
		var cutout_in := cutout_circle
		var cutout_out := cutout_circle
		var transition_time := 0.75
		Singleton.Music.stop_temporary_music()
		
		match(cause):
			"fall":
				controllable = false
				sound_player.play_fall_sound()
				if number_of_players == 1:
					cutout_in = cutout_death
					yield(get_tree().create_timer(1), "timeout")
				else:
					reload = false
			"reload":
				transition_time = 0.4
			"green_demon":
				sound_player.play_last_hit_sound()
				controllable = false
				movable = false
				cutout_in = cutout_death
				sprite.visible = false
				death_sprite.set_as_toplevel(true)
				death_sprite.global_position = sprite.global_position
				death_sprite.play_anim()
				position = Vector2(0, 100000000000000000)
				reset_physics_interpolation()
				yield(get_tree().create_timer(0.55), "timeout")
				sound_player.play_death_sound()
				yield(get_tree().create_timer(0.75), "timeout")
			"hit", "lava", "crushed":
				controllable = false
				movable = false
				cutout_in = cutout_death
				sprite.visible = false
				death_sprite.set_as_toplevel(true)
				death_sprite.global_position = sprite.global_position
				death_sprite.play_anim()
				position = Vector2(0, 100000000000000000)
				reset_physics_interpolation()
				yield(get_tree().create_timer(0.55), "timeout")
				sound_player.play_death_sound()
				yield(get_tree().create_timer(0.75), "timeout")
				if number_of_players != 1:
					reload = false
			"timer":
				sound_player.play_last_hit_sound()
				controllable = false
				movable = false
				cutout_in = cutout_death
				sprite.visible = false
				death_sprite.set_as_toplevel(true)
				death_sprite.global_position = sprite.global_position
				death_sprite.play_anim()
				position = Vector2(0, 100000000000000000)
				reset_physics_interpolation()
				yield(get_tree().create_timer(0.55), "timeout")
				sound_player.play_death_sound()
				yield(get_tree().create_timer(0.75), "timeout")
				reload = true
			"quicksand":
				controllable = false
				disable_movement = true
#				sprite.animation = "bonkedLeft" if facing_direction == -1 else "bonkedRight"
				sprite.animation = "jumpRight"
#				sprite.speed_scale = 0
#				sprite.frame = 0
				sound_player.play_death_sound()
				if number_of_players == 1:
					cutout_in = cutout_death
					yield(get_tree().create_timer(1), "timeout")
				else:
					reload = false
			"poison":
				sound_player.play_last_hit_sound()
				controllable = false
				movable = false
				cutout_in = cutout_death
				sprite.visible = false
				death_sprite.set_as_toplevel(true)
				death_sprite.global_position = sprite.global_position
				death_sprite.play_anim()
				position = Vector2(0, 100000000000000000)
				reset_physics_interpolation()
				yield(get_tree().create_timer(0.55), "timeout")
				sound_player.play_death_sound()
				yield(get_tree().create_timer(0.75), "timeout")
				
			
		if reload:
			Singleton.SceneTransitions.reload_scene(cutout_in, cutout_out, transition_time, 0, true)
		else:
			yield(get_tree().create_timer(3), "timeout")
			set_powerup(null, false)
			
			health = 8
			health_shards = 0
			emit_signal("health_changed", health, health_shards)
			
			if Singleton.CheckpointSaved.current_checkpoint_id != -1 and Singleton.CheckpointSaved.current_area == Singleton.CurrentLevelData.area and Singleton.CurrentLevelData.level_data.vars.transition_data == []:
				position = Singleton.CheckpointSaved.current_spawn_pos
				reset_physics_interpolation()
				GhostArrays.dont_save = true
			else:
				position = spawn_pos - Vector2(0, 16)
				reset_physics_interpolation()
			last_position = position # fixes infinite death bug
			dead = false
			movable = true
			sprite.visible = true
			death_sprite.visible = false
			controllable = true
			Singleton.CurrentLevelData.can_pause = true
			set_state_by_name("FallState", 0)

func exit() -> void:
	#if the mode switcher button is not invisible, we're in edit mode, switch back to that, but if we're in play mode then for now just reload the scene
	if !Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible:
		Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switch()
	else: 
		# warning-ignore: return_value_discarded
		get_tree().reload_current_scene()


onready var terrain_collision_nodes: Array = [
	self,
	ground_check,
	ground_check_dive,
	left_check,
	right_check,
	slope_stop_check,
	squish_vertical_check,
	squish_vertical_check_dive,
	squish_left_check,
	squish_right_check
]
func set_all_collision_masks(bit, value) -> void:
	for collision_node in terrain_collision_nodes:
		collision_node.set_collision_mask_bit(bit, value)


func get_input(input_id : int, is_just_pressed : bool) -> bool:
	return inputs[input_id][int(is_just_pressed)]

func update_inputs() -> void:
	if controlled_locally:
		var control_id := player_id
		for input in inputs:
			input[0] = Input.is_action_pressed(input[2] + str(control_id))
			input[1] = Input.is_action_just_pressed(input[2] + str(control_id))

func set_inter_player_collision(can_collide : bool) -> void:
	player_collision.set_collision_mask_bit(1, can_collide)
	player_collision.set_collision_layer_bit(1, can_collide)

func set_dive_collision(is_enabled : bool) -> void:
	using_dive_collision = is_enabled
	if is_enabled:
		ground_shape.disabled = is_enabled
	else:
		ground_collider_enable_timer.start()
	collision_raycast.disabled = is_enabled
	dive_collision_shape.disabled = !is_enabled
	ground_collision_dive.disabled = !is_enabled
	left_collision.disabled = is_enabled
	right_collision.disabled = is_enabled

func hide_shine_dance_shine():
	$CollectedShine.visible = false
	$CollectedShineOutline.visible = false
	
func _connect_signals():
	for i in $Powerups.get_children():
		i.connect("powerup_state_changed", self, "_on_powerup_state_changed")

func set_collision(value : bool):
	set_collision_layer_bit(1, value) # disable collisions w/ most things
	set_inter_player_collision(value)

func _on_powerup_state_changed(powerup_id: String): # ====================================================================
	match powerup_id:                               # | This is here to keep sound.gd from polling every frame to see if | 
													# | the player gets a metal powerup so it can switch effects buses.  |
		"Normal":									# ====================================================================
			sound_player.voice_effects.set_bus(sound_player.normal_bus)
		"Metal":                                           
			sound_player.voice_effects.set_bus(sound_player.metal_bus)

		_:
			pass

func _on_heal_timer_timeout():
	overheal_enabled = false
	healing_timer_enabled = false
	regen_particles.emitting = false

func _on_heal_tick_timer_timeout():
	if healing_timer_enabled:
		if health >= 8 && !overheal_enabled:
			heal_timer.wait_time = 0.001
			heal_timer.start()
			return
		heal(1)
		heal_tick_timer.start()

func _on_ground_collder_timer_timeout():
	ground_shape.disabled = false

func toggle_movement(var value : bool):
	invulnerable = !value
	controllable = value
	movable = value

func handle_liquids(liquid_areas, delta):
	quicksand_particles.emitting = false
	quicksand_particles2.emitting = false
	if liquid_areas.size() <= 0: return
	
	for area in liquid_areas:
		var liquid : LiquidBase = area.get_parent()
		match(liquid.liquid_type):
			liquid.LiquidType.Water:
				pass
				
			liquid.LiquidType.Lava:
				pass
				
			liquid.LiquidType.Quicksand:
				var sinking_speed = liquid.sinking_speed/10
				var death_threshold = liquid.death_threshold
				
				if death_threshold <= 0 and !dead:
					kill("quicksand")
				if dead:
					velocity = Vector2(0, sinking_speed*6)
				
				var rotation_vector : Vector2 = liquid.global_transform.y
				
				var m = rotation_vector.x/rotation_vector.y
				var b = liquid.global_position.y - m*(liquid.global_position.x)
				
				var top_position := Vector2(
					(global_position.y - b) / m if m != 0 else global_position.x,
					global_position.x * m + b
					)
				
#				if state != get_state_node("QuicksandIdleState") or state != get_state_node("QuicksandHopState"):
#					set_state_by_name("QuicksandIdleState")
				var idle_state = get_state_node("QuicksandIdleState")
				var hop_state = get_state_node("QuicksandHopState")
				
				
				idle_state.fall_speed = sinking_speed
				
				if bottom_pos.global_position.y < liquid.global_position.y + 2:
					hop_state.working_jump_strength = get_state_node("JumpState").jump_power
					idle_state.move_speed_modifier = .9
				else:
					hop_state.working_jump_strength = get_state_node("QuicksandHopState").jump_strength
					
					if !dead:
						idle_state.move_speed_modifier = min(1-(((bottom_pos.global_position.y-liquid.global_position.y)/death_threshold)/1.75), .75)
					
					quicksand_particles.process_material.color = liquid.color/1.2
					quicksand_particles2.process_material.color = liquid.color/1.2
					quicksand_particles.emitting = true
					quicksand_particles2.emitting = true
			
				if bottom_pos.global_position.y > top_position.y + death_threshold*rotation_vector.y and !dead:
					print(top_position)
					print(global_position)
					kill("quicksand")

			liquid.LiquidType.Poison:
				kill("poison")
