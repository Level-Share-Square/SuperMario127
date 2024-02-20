# TODO:
# disable rotations in the editor 
extends GameObject

onready var pipe_enter_logic : Node2D = $PipeEnterLogic
onready var cannon_exit_position : Position2D = $CannonMoveable/SpriteBodyReverser/SpriteBody/CannonExitPosition
onready var entrance_collision : StaticBody2D = $EntranceCollision
onready var cannon_moveable : Node2D = $CannonMoveable
onready var cannon_camera_startup_focus = $CannonMoveable/CameraFocusStartup
onready var cannon_camera_focus : Position2D = $CannonMoveable/SpriteBodyReverser/SpriteBody/CameraFocus
onready var sprite_body : Sprite = $CannonMoveable/SpriteBodyReverser/SpriteBody
onready var sprite_body_reverser : Node2D = $CannonMoveable/SpriteBodyReverser
onready var sprite_fuse : AnimatedSprite = $CannonMoveable/SpriteBodyReverser/SpriteBody/SpriteFuse
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var tween : Tween = $Tween 
onready var timer : Timer = $Timer
onready var invuln_timer = $InvulnTimer
onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
onready var particles : Particles2D = $CannonMoveable/SpriteBodyReverser/SpriteBody/Particles2D
onready var nearby_character_detection : Area2D = $NearbyCharacterDetection

# the character using the cannon
var stored_character : Character

# when the cannon faces left, this is -1, so it's used for ensuring everything is properly flipped when facing left
var cannon_direction_multiplier := 1

# constants used for the animations immediately after firing the cannon
const ROTATION_RETURN_DELAY := 0.3
const ROTATION_RETURN_TIME := 0.3
const FIRE_STRETCH_TIME := 0.1 #the stretching animation that happens just after firing mario out 
const FIRE_UNSTRETCH_TIME := 0.05
const FIRE_STRETCH_MULTIPLIER := 1.2

# cannon moves to the background while in use so other characters walk in front of it, but if it's not in the foreground as well when entering it you'll appear on top
const Z_INDEX_FOREGROUND := 0
const Z_INDEX_BACKGROUND := -5 

# properties that can be changed in the editor
var launch_power := 1200
const MAX_LAUNCH_POWER := 10000 
var min_rotation := 0
var max_rotation := 90
var faces_right := true
	
# the audio files used in the code for some of the cannons movements
onready var cannon_move_noise : AudioStream = preload("res://scenes/actors/objects/cannon/crank.tres")
onready var cannon_fire_noise : AudioStream = preload("res://scenes/actors/objects/cannon/nsmbwiiBobombCannon.wav")

func _set_properties() -> void:
	savable_properties = ["launch_power", "min_rotation", "max_rotation", "faces_right"]
	editable_properties = ["launch_power", "min_rotation", "max_rotation", "faces_right"]
	
func _set_property_values() -> void:
	set_property("launch_power", launch_power)
	set_property("min_rotation", min_rotation)
	set_property("max_rotation", max_rotation)
	set_property("faces_right", faces_right)

func _ready() -> void:
	set_physics_process(false)

	if !faces_right:
		sprite_body_reverser.scale.x *= -1
		sprite_body.scale.x *= -1 #what this will do is make sure the sprite has consistent lighting regardless of the side
		cannon_direction_multiplier = -1
	# warning-ignore:return_value_discarded
	pipe_enter_logic.connect("pipe_animation_finished", self, "_start_cannon_animation")

#disabled by default until process is enabled, so this can assume the cannon is already in an active state
func _physics_process(delta : float) -> void:
	if launch_power > MAX_LAUNCH_POWER:
		launch_power = MAX_LAUNCH_POWER

	#if the jump button is pressed, fire the cannon
	if stored_character.get_input(Character.input_names.fludd, true) or (stored_character.get_input(Character.input_names.jump, true) and !stored_character.get_input(Character.input_names.up, true)):
		set_physics_process(false)

		audio_player.set_process(true)

		fire_cannon()

		#cannon recoil animation so the shot has more power
		# warning-ignore: return_value_discarded
		tween.interpolate_property(sprite_body, "scale:y", null, scale.y * FIRE_STRETCH_MULTIPLIER, FIRE_STRETCH_TIME)
		# warning-ignore: return_value_discarded
		tween.interpolate_property(sprite_body, "scale:y", scale.y * FIRE_STRETCH_MULTIPLIER, scale.y, FIRE_UNSTRETCH_TIME, \
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, FIRE_STRETCH_TIME) 

		#return cannon to pointing straight up
		# warning-ignore: return_value_discarded
		tween.interpolate_property(sprite_body, "rotation_degrees", null, 0, ROTATION_RETURN_TIME, \
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, FIRE_STRETCH_TIME + FIRE_UNSTRETCH_TIME + ROTATION_RETURN_DELAY) 
		
		# warning-ignore: return_value_discarded
		tween.start()
		
		return

	#booleans when converting to integer are 0 or 1, so doing right - left means when right is pressed, it'll be 1, 
	#when left is pressed it'll be -1, and when both/neither are pressed it'll be 0
	var horizontal_input : int = int(stored_character.get_input(Character.input_names.right, false)) \
			- int(stored_character.get_input(Character.input_names.left, false))
	horizontal_input *= cannon_direction_multiplier

	if horizontal_input != 0:
		sprite_body.rotation += horizontal_input * fps_util.PHYSICS_DELTA
		sprite_body.rotation = clamp(sprite_body.rotation, deg2rad(min_rotation), deg2rad(max_rotation))

	audio_player.stream_paused = horizontal_input == 0 or sprite_body.rotation_degrees == min_rotation \
			or sprite_body.rotation_degrees == max_rotation #the stream used for the cannon move sound is set in the cannon startup animation finish function

# called by a signal when the pipe enter animation finished
func _start_cannon_animation(character : Character, entering : bool) -> void:
	stored_character = character
	stored_character.modulate.a = 0
	stored_character.camera.focus_on = cannon_camera_startup_focus

	cannon_moveable.z_index = Z_INDEX_BACKGROUND
	
	#collision_shape.disabled = true
	entrance_collision.set_collision_layer_bit(0, false)

	animation_player.play("cannon_startup")

func _on_animation_finished(anim_name : String) -> void:
	if anim_name == "cannon_startup":
		stored_character.camera.focus_on = cannon_camera_focus
		stored_character.controllable = true
		stored_character.set_state_by_name("NoActionState", get_physics_process_delta_time())
		stored_character.camera.set_zoom_tween(Vector2(1.5, 1.5), 0.8)
		sprite_fuse.visible = true

		#normally we would change current volume, but process for the audio stream player is disabled until the cannon fires
		audio_player.volume_db = -10 #needs to be a bit quieter to sound right
		audio_player.stream = cannon_move_noise
		audio_player.play()
		audio_player.stream_paused = true #pause it so we can unpause it when the cannon is moving

		set_physics_process(true)
	else: #right now the only other animation is the retract, if this changes, change this to an elif
		attempt_enable_collision()
		
		audio_player.set_process(false)

#after the tween is done, the cannon is pointing straight up and needs to retract so it can be used again
func _on_tween_all_completed() -> void:
	animation_player.play("cannon_retract")
	sprite_fuse.visible = false

func fire_cannon() -> void:
	#return the player control and such to normal 
	stored_character.invulnerable = false
	stored_character.controllable = true
	stored_character.movable = true
	stored_character.modulate.a = 1
	stored_character.camera.zoom_tween.remove_all()
	stored_character.camera.set_zoom_tween(Vector2(1,1), 0.5)
	invuln_timer.start()
	#set the player so they will fire out of the cannon properly with velocity and such
	stored_character.position = cannon_exit_position.global_position
	stored_character.last_position = stored_character.position # Prevent the patch from triggering
	stored_character.velocity = Vector2.UP.rotated(sprite_body.rotation * cannon_direction_multiplier) * launch_power
	stored_character.facing_direction = cannon_direction_multiplier
	stored_character.set_state_by_name("DiveState", get_physics_process_delta_time())

	#play cannon fire sound
	audio_player.stream = cannon_fire_noise
	audio_player.current_volume = 10 # use current_volume since the audio_players process will be enabled now
	audio_player.stream_paused = false #the cannon aiming sfx uses the pause feature to play it properly, so no audio will play unless we set this
	audio_player.play()
	
	#cannon fire particles 
	particles.emitting = true
	#in case an enemy is too close, this timer keeps mario from getting damaged while being shot
	invuln_timer.start()
	var _invuln_connect = timer.connect("timeout", self, "_on_invuln_timeout", [], CONNECT_ONESHOT)
	#start timer to return the camera
	timer.start()
	var _connect = timer.connect("timeout", self, "return_camera_focus", [], CONNECT_ONESHOT)

func return_camera_focus() -> void:
	stored_character.camera.focus_on = null

func _on_invuln_timeout():
	stored_character.set_collision_layer_bit(1, true)
#used to re-enable the entrance collision only when a player exits the vicinity
func _on_NearbyCharacterDetection_body_exited(body : PhysicsBody2D) -> void:
	attempt_enable_collision(body)

func attempt_enable_collision(body : PhysicsBody2D = null) -> void:
	var overlapping_bodies = nearby_character_detection.get_overlapping_bodies()

	#body is passed to this by the body exited call, if body isn't provided then this is the call from 
	#after the cannon finishes retracting
	if body: 
		overlapping_bodies.erase(body) #we know this body isn't in anymore, since the method was called after all
	
	#physics process being enabled for the cannon only happens when the player is controlling it, and we don't 
	#want the cannon to have a hitbox during that
	var can_enable_collision : bool = (overlapping_bodies.size() == 0 and !is_physics_processing())

	entrance_collision.set_collision_layer_bit(0, can_enable_collision)
	pipe_enter_logic.is_idle = can_enable_collision
	
	# simple little math thing, if can_enable_collision is true, it'll be a 1, if false it'll be a 0, 
	#so one of the values will be multiplied by 0 and therefore impact anything
	cannon_moveable.z_index = Z_INDEX_FOREGROUND * int(can_enable_collision) + Z_INDEX_BACKGROUND * int(!can_enable_collision)
