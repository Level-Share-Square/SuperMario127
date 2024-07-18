extends GameObject

onready var speed_tween = $Tween
onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var player_detector = $PlayerDetector
onready var animation_player = $AnimationPlayer
onready var launch_noise : AudioStream = preload("res://scenes/actors/objects/sling_star/sfx/launch.wav")
onready var windup_noise : AudioStream = preload("res://scenes/actors/objects/sling_star/sfx/windup.wav")
onready var star = $Star

enum states {IDLE, HOLDING, WINDUP, LAUNCH}
var state = states.IDLE
var mario : Character
#amount of time mario stays floating in the launch star before being dropped
var float_timer = 4

var launch_power : float = 10.0

var parts := 1
var last_parts := 1

var cooldown = 0.0

func _set_properties():
	savable_properties = ["launch_power"]
	editable_properties = ["launch_power"]
	
func _set_property_values():
	set_property("launch_power", launch_power, 10)
	
func set_state(to:int):
	match(to):
		states.IDLE:
			mario.camera.auto_move = true
			state = states.IDLE
			return
		states.HOLDING:
			star.global_position = position
			mario.set_state_by_name("LaunchStarState", fps_util.PHYSICS_DELTA)
			mario.anim_player.stop()
			if(rotation_degrees < -180):
				mario.facing_direction = 1
			elif(rotation_degrees > -180 and rotation_degrees != 0):
				mario.facing_direction = -1
			state = states.HOLDING
			return
		states.WINDUP:
			star.global_position = position
			animation_player.play("windup")
			audio_player.stop()
			audio_player.stream = windup_noise
			audio_player.play()
			mario.sprite.frame = 5
			speed_tween.interpolate_property(mario.sprite, "speed_scale", mario.sprite.speed_scale*2, 0.1, 0.7, 1)
			speed_tween.start()
			mario.sprite.rotation_degrees = rotation_degrees
			mario.anim_player.stop()
			state = states.WINDUP
			return
		states.LAUNCH:
			animation_player.play("launch")
			audio_player.stop()
			audio_player.stream = launch_noise
			audio_player.play()
			speed_tween.remove_all()
			if is_instance_valid(mario.state):
				mario.state._stop(fps_util.PHYSICS_DELTA)
			mario.velocity = Vector2(1, -launch_power * 80).rotated(rotation)
			mario.sound_player.play_double_jump_sound()
			state = states.LAUNCH
			return
	
func _ready():
	if is_preview:
		z_index = 2

func _input(event):
	pass

func _process(delta):
	pass
	
func _physics_process(delta):
	if enabled and mode == 0:
		
		match(state):
			states.IDLE:
				physics_process_idle(delta)
			states.HOLDING:
				physics_process_holding(delta)
			states.WINDUP:
				physics_process_windup(delta)
			states.LAUNCH:
				physics_process_launch(delta)

# the launch star is waiting for mario to enter it
func physics_process_idle(delta:float):
	
	for body in player_detector.get_overlapping_bodies():
		if body.name.begins_with("Character"):
			mario = body
			# mid flight interrupt
			if body.inputs[4][0] and body.state and body.state.name == "LaunchStarState":
				mario.state._stop(delta)
				mario.set_state_by_name("LaunchStarState", delta)
				set_state(2)
				mario.camera.auto_move = true
				
			# special behavior for powerups
			if is_instance_valid(mario.powerup) and (mario.powerup.get_name() == "WingPowerup" or mario.powerup.get_name() == "RainbowPowerup"):
				if mario.powerup.get_name() == "WingPowerup" and is_instance_valid(mario.state):
					mario.state._stop(delta)
					mario.set_state_by_name("LaunchStarState", delta)
				set_state(2)
			#this is what lets mario fall
			if float_timer > 0 and body.state and body.state.name != "LaunchStarState":
				set_state(1)
				
			return
	
	float_timer = 3
	
# the sling star is holding mario waiting for him to spin
func physics_process_holding(delta:float):
	mario.velocity = Vector2(0,0)
	float_timer -= delta
	if(float_timer <= 0):
		mario.state._stop(delta)
		set_state(0)
		return
	mario.position = lerp(mario.position, position, 0.1)
	mario.sprite.rotation = lerp_angle(mario.sprite.rotation, rotation, 0.07)
	if mario.inputs[4][0]:
		set_state(2)
		return
		
func physics_process_windup(delta:float):
	mario.position = to_global(star.position)
		
# the launch star is launching mario
func physics_process_launch(delta:float):
	pass

