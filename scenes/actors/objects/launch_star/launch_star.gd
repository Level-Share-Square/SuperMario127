extends GameObject



onready var path : Path2D = $Path2D
onready var pathfollow = $Path2D/PathFollow2D
onready var star_container = $StarContainer
onready var innerstar = $StarContainer/InnerStar
onready var speed_tween = $SpeedTween
onready var animation_player = $AnimationPlayer
onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var fly_noise_player : AudioStreamPlayer2D = $AudioStreamPlayer2D2
onready var player_detector = $PlayerDetector
onready var launch_noise : AudioStream = preload("res://scenes/actors/objects/launch_star/sfx/launch.wav")
onready var flying_noise : AudioStream = preload("res://scenes/actors/objects/launch_star/sfx/flying.wav")
onready var windup_noise : AudioStream = preload("res://scenes/actors/objects/launch_star/sfx/windup.wav")
onready var launch_particles : CPUParticles2D = $LaunchParticles

enum states {IDLE, HOLDING, WINDUP, LAUNCH}
var state = states.IDLE
var mario : Character
#amount of time mario stays floating in the launch star before being dropped
var float_timer = 4
var last_position

var speed = 10
var curve = Curve2D.new()
var custom_path = Curve2D.new()





func _set_properties():
	savable_properties = ["curve", "custom_path", "speed"]
	editable_properties = ["custom_path", "speed"]

func _set_property_values():
	set_property("curve", curve)
	set_property("custom_path", curve)
	set_property("speed", speed)

func invalid_curve(check : Curve2D):
	if(!is_instance_valid(check) or check.get_point_count() == 0):
		return true
	else:
		return false
		
func set_camera():
	#print("set camera")
	if mario.movable:
		mario.camera.auto_move = true
		
func set_state(to:int):
	match(to):
		states.IDLE:
			pathfollow.offset = 100
			fly_noise_player.stop()
			mario.camera.auto_move = true
			mario.disconnect("state_changed", self, "cancel_launch")
			state = states.IDLE
			return
		states.HOLDING:
			innerstar.global_position = position
			mario.set_state_by_name("LaunchStarState", fps_util.PHYSICS_DELTA)
			mario.connect("state_changed", self, "cancel_launch")
			mario.anim_player.stop()
			if(rotation_degrees < -180):
				mario.facing_direction = 1
			elif(rotation_degrees > -180 and rotation_degrees != 0):
				mario.facing_direction = -1
			state = states.HOLDING
			return
		states.WINDUP:
			innerstar.global_position = position
			animation_player.play("windup")
			audio_player.stop()
			audio_player.stream = windup_noise
			audio_player.play()
			mario.sprite.frame = 6
			speed_tween.interpolate_property(mario.sprite, "speed_scale", mario.sprite.speed_scale*2, 0, 0.7, 1)
			speed_tween.start()
			
			mario.sprite.rotation_degrees = rotation_degrees
			state = states.WINDUP
			return
		states.LAUNCH:
			animation_player.play("launch")
			audio_player.stop()
			audio_player.stream = launch_noise
			audio_player.play()
			fly_noise_player.stream = flying_noise
			fly_noise_player.play()
			speed_tween.remove_all()
			mario.sound_player.play_triple_jump_sound()
			mario.sprite.speed_scale = 1.5
			mario.camera.auto_move = false
			state = states.LAUNCH
			return
	
func _ready():
#	launch_particles.emitting = false
	if(invalid_curve(curve)):
		curve.add_point(Vector2())
		curve.add_point(Vector2(0, -600))
	if(invalid_curve(path.curve)):
		path.curve = curve
	last_position = position
	pathfollow.offset = 100
	star_container.look_at(position + path.curve.get_point_position(1))
	star_container.rotation_degrees += 90
	player_detector.look_at(position + path.curve.get_point_position(1))
	player_detector.rotation_degrees += 90
	
func _process(_delta):
	if curve != path.curve:
		path.curve = curve		
func _physics_process(delta):
	if mode != 0:
		star_container.look_at(position + path.curve.get_point_position(1))
		star_container.rotation_degrees += 90
		player_detector.look_at(position + path.curve.get_point_position(1))
		player_detector.rotation_degrees += 90
		launch_particles.direction = Vector2.UP.rotated(deg2rad(star_container.rotation_degrees))
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
			if body.inputs[4][0] and body.state and body.state.name == "LaunchStarState":
				mario.state._stop(delta)
				set_state(3)
			#this is what lets mario fall
			if float_timer > 0 and body.state and body.state.name != "LaunchStarState":
				set_state(1)
			return
	float_timer = 3
# the launch star is holding mario waiting for him to spin
func physics_process_holding(delta:float):
	mario.velocity = Vector2(0,0)
	float_timer -= delta
	if(float_timer <= 0):
		mario.state._stop(delta)
		return
	mario.position = lerp(mario.position, position, 0.1)
	mario.reset_physics_interpolation()
	mario.sprite.rotation = lerp_angle(mario.sprite.rotation, pathfollow.rotation + 1.571, 0.07)
	if mario.inputs[4][0]:
		set_state(2)
		return
		
func physics_process_windup(delta:float):
	# for mid-launch launch
	if(mario.state and mario.state.name != "LaunchStarState"):
		mario.set_state_by_name("LaunchStarState", delta)
		mario.connect("state_changed", self, "cancel_launch")	
	mario.position = innerstar.global_position
	mario.reset_physics_interpolation()
	mario.sprite.look_at(position + pathfollow.position)
	mario.sprite.rotation_degrees += 90
		
# the launch star is launching mario
func physics_process_launch(delta:float):
	var dif = to_global(pathfollow.position) - last_position
	if !pathfollow.offset >= path.curve.get_baked_length():
		last_position = to_global(pathfollow.position)
	

	#mario.sprite.look_at(position + pathfollow.position)
	mario.sprite.rotation = lerp_angle(mario.sprite.rotation, pathfollow.rotation + PI/2, clamp(0.008 * speed, 0, 1))
	#mario.sprite.rotation_degrees += 90
	
	

	# reached end
	#todo: fix exit velocity
	if pathfollow.offset >= path.curve.get_baked_length(): 
		mario.position = mario.position.move_toward(position + pathfollow.position, speed)
		mario.reset_physics_interpolation()
		if mario.position.distance_to(position + pathfollow.position) <= 10:
			mario.velocity = Vector2(0, -speed).rotated(mario.sprite.rotation) * 60
			mario.facing_direction = sign(mario.velocity.x)
			mario.state._stop(delta)
			
			mario.last_position = mario.position
	else:
		pathfollow.offset += speed
		mario.position = lerp(mario.position, position + pathfollow.position, clamp(0.008 * speed, 0, 1))
		mario.reset_physics_interpolation()
	mario.last_position = mario.position
func cancel_launch(new, old):
	set_state(0)

