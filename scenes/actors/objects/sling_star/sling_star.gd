extends GameObject

onready var speed_tween = $Tween
onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var player_detector = $PlayerDetector
onready var launch_noise : AudioStream = preload("res://scenes/actors/objects/sling_star/sfx/launch.wav")
onready var windup_noise : AudioStream = preload("res://scenes/actors/objects/sling_star/sfx/windup.wav")
onready var star = $Star

enum states {IDLE, HOLDING, PRELAUNCH, LAUNCH}
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
	
func _ready():
	pass

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
			states.PRELAUNCH:
				physics_process_prelaunch(delta)
			states.LAUNCH:
				physics_process_launch(delta)

# the launch star is waiting for mario to enter it
func physics_process_idle(delta:float):
	
	for body in player_detector.get_overlapping_bodies():
		if body.name.begins_with("Character"):
			
			# mid flight interrupt
			if body.inputs[4][0] and body.state and body.state.name == "LaunchStarState":
				mario = body
				mario.state._stop(delta)
				mario.set_state_by_name("LaunchStarState", delta)
				state = states.PRELAUNCH
				speed_tween.interpolate_method(star, "change_speed", 50, 0, 1, 1, 1)
				speed_tween.interpolate_property(star, "position", star.position, star.position + Vector2(0, 20), 1, 0, 1)
				mario.sprite.frame = 3
				speed_tween.interpolate_property(mario.sprite, "speed_scale", mario.sprite.speed_scale*2, 0.1, 1, 1, 1)
				speed_tween.start()
				audio_player.stream = windup_noise
				audio_player.play()
				mario.camera.auto_move = true
			#this is what lets mario fall
			if float_timer > 0 and body.state and body.state.name != "LaunchStarState":
				print("catching")
				mario = body
				mario.set_state_by_name("LaunchStarState", delta)
				state = states.HOLDING
				
			return
	
	float_timer = 3
	
# the sling star is holding mario waiting for him to spin
func physics_process_holding(delta:float):
	mario.velocity = Vector2(0,0)
	float_timer -= delta
	if(float_timer <= 0):
		state = states.IDLE
		mario.state._stop(delta)
		return
	mario.position = lerp(mario.position, position, 0.1)
	mario.sprite.rotation = lerp_angle(mario.sprite.rotation, rotation, 0.07)
	if mario.inputs[4][0]:
		state = states.PRELAUNCH
		speed_tween.interpolate_method(star, "change_speed", 50, 0, 0.7, 1, 1)
		speed_tween.interpolate_property(star, "position", star.position, star.position + Vector2(0, 20), 0.7, 0, 1)
		mario.sprite.frame = 3
		speed_tween.interpolate_property(mario.sprite, "speed_scale", mario.sprite.speed_scale*2, 0.1, 0.7, 1, 1)
		speed_tween.start()
		audio_player.stream = windup_noise
		audio_player.play()
		return
		
func physics_process_prelaunch(delta:float):
	mario.position = to_global(star.position)
	mario.sprite.rotation = lerp_angle(mario.sprite.rotation, rotation, 0.07)
	print(mario.sprite.speed_scale)
	if !speed_tween.is_active():
		speed_tween.interpolate_method(star, "change_speed", 0, 1, 0.5, 1, 1)
		speed_tween.interpolate_property(star, "position", star.position, star.position - Vector2(0, 20), 1.5, 6, 1)
		speed_tween.start()
		audio_player.stream = launch_noise
		audio_player.play()
		mario.velocity = Vector2(1, -launch_power * 80).rotated(rotation)
		mario.state._stop(delta)
		mario.sound_player.play_double_jump_sound()
		float_timer = 0
		state = states.IDLE
	
		
# the launch star is launching mario
func physics_process_launch(delta:float):
	cooldown -= delta
	mario.sprite.rotation = lerp_angle(mario.sprite.rotation, 0, 0.07)
	if(cooldown <= 0):
		mario.sprite.rotation = 0
		state = states.IDLE

