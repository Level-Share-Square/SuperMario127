extends GameObject



onready var path : Path2D = $Path2D
onready var pathfollow = $Path2D/PathFollow2D
onready var innerstar = $InnerStar
onready var outerstar = $OuterStar
onready var speed_tween = $SpeedTween
onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var fly_noise_player : AudioStreamPlayer2D = $AudioStreamPlayer2D2
onready var player_detector = $PlayerDetector
onready var launch_noise : AudioStream = preload("res://scenes/actors/objects/launch_star/sfx/launch.wav")
onready var flying_noise : AudioStream = preload("res://scenes/actors/objects/launch_star/sfx/flying.wav")
onready var windup_noise : AudioStream = preload("res://scenes/actors/objects/launch_star/sfx/windup.wav")

enum states {IDLE, HOLDING, PRELAUNCH, LAUNCH}
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
		

func _ready():
	# first creation of object
	if(invalid_curve(curve)):
		curve.add_point(Vector2())
		curve.add_point(Vector2(0, -600))
	if(invalid_curve(path.curve)):
		path.curve = curve
	last_position = position
	pathfollow.offset = 100
		
func _process(_delta):
	if curve != path.curve:
		path.curve = curve		
func _physics_process(delta):
	innerstar.look_at(position + path.curve.get_point_position(1))
	outerstar.look_at(position + path.curve.get_point_position(1))
	player_detector.look_at(position + path.curve.get_point_position(1))
	innerstar.rotation_degrees += 90
	outerstar.rotation_degrees += 90
	player_detector.rotation_degrees += 90
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
			#if mario triggers a launch star while already launching
			if body.inputs[4][0] and body.state and body.state.name == "LaunchStarState":
				mario = body
				mario.state._stop(delta)
				mario.set_state_by_name("LaunchStarState", delta)
				mario.connect("state_changed", self, "cancel_launch")
				state = states.PRELAUNCH
				speed_tween.interpolate_method(outerstar, "change_speed", 50, 0, 1, 1, 1)
				speed_tween.interpolate_method(innerstar, "change_speed", 50, 0, 1, 1, 1)
				speed_tween.interpolate_property(innerstar, "position", innerstar.position, (innerstar.position + Vector2(0, 20)).rotated(innerstar.rotation), 1, 0, 1)
				mario.sprite.frame = 4
				mario.sprite.rotation = pathfollow.rotation + 1.571
				speed_tween.interpolate_property(mario.sprite, "speed_scale", mario.sprite.speed_scale*2, 0.1, 1, 1, 1)
				speed_tween.start()
				audio_player.stream = windup_noise
				audio_player.play()
			#this is what lets mario fall
			if float_timer > 0 and body.state and body.state.name != "LaunchStarState":
				mario = body
				mario.set_state_by_name("LaunchStarState", delta)
				mario.connect("state_changed", self, "cancel_launch")
				state = states.HOLDING
			return
	float_timer = 3
# the launch star is holding mario waiting for him to spin
func physics_process_holding(delta:float):
	mario.velocity = Vector2(0,0)
	float_timer -= delta
	if(float_timer <= 0):
		state = states.IDLE
		mario.state._stop(delta)
		return
	mario.position = lerp(mario.position, position, 0.1)
	mario.sprite.rotation = lerp_angle(mario.sprite.rotation, pathfollow.rotation + 1.571, 0.07)
	if mario.inputs[4][0]:
		state = states.PRELAUNCH
		speed_tween.interpolate_method(outerstar, "change_speed", 50, 0, 1, 1, 1)
		speed_tween.interpolate_method(innerstar, "change_speed", 50, 0, 1, 1, 1)
		speed_tween.interpolate_property(innerstar, "position", innerstar.position, (innerstar.position + Vector2(0, 20)).rotated(innerstar.rotation), 1, 0, 1)
		mario.sprite.frame = 4
		mario.sprite.rotation = pathfollow.rotation + 1.571
		
		speed_tween.interpolate_property(mario.sprite, "speed_scale", mario.sprite.speed_scale*2, 0.1, 1, 1, 1)
		speed_tween.start()
		audio_player.stream = windup_noise
		audio_player.play()
		return
		
func physics_process_prelaunch(delta:float):
	# for mid-launch launch
	if(mario.state and mario.state.name != "LaunchStarState"):
		mario.set_state_by_name("LaunchStarState", delta)
		
	if !speed_tween.is_active():
		
		speed_tween.interpolate_method(outerstar, "change_speed", 0, 1, 0.5, 1, 1, 0)
		speed_tween.interpolate_method(innerstar, "change_speed", 0, 1, 0.5, 1, 1, 0)
		speed_tween.interpolate_property(innerstar, "position", innerstar.position, outerstar.position, 0.5, 6, 1)
		speed_tween.start()
		mario.sprite.speed_scale = 1.5
		mario.sound_player.play_triple_jump_sound()
		audio_player.stream = launch_noise
		audio_player.play()
		fly_noise_player.stream = flying_noise
		fly_noise_player.play()
		state = states.LAUNCH
		
	mario.position = to_global(innerstar.position)
	pass
		
# the launch star is launching mario
func physics_process_launch(delta:float):	
	pathfollow.offset += speed
	var dif = to_global(pathfollow.position) - last_position
	print(dif)
	if !pathfollow.offset >= path.curve.get_baked_length():
		last_position = to_global(pathfollow.position)
	

	mario.sprite.look_at(to_global(pathfollow.position))
	mario.sprite.rotation_degrees += 90
	mario.position = lerp(mario.position, position + pathfollow.position, clamp(0.008 * speed, 0, 1))

	if speed_tween.is_active():
		mario.camera.auto_move = false
	else:
		mario.camera.auto_move = true
	# reached end
	#todo: fix exit velocity
	
	if pathfollow.offset >= path.curve.get_baked_length() and mario.position.distance_to(to_global(pathfollow.position)) <= 36:
		mario.velocity = dif
		mario.velocity = Vector2(0, -speed)
		mario.state._stop(delta)
		state = states.IDLE
		mario.velocity = Vector2(0, -speed)
		mario.velocity = dif.rotated(mario.get_angle_to(to_global(pathfollow.position)) + 1.571) * speed
		mario.velocity = Vector2(0, -speed).rotated(mario.get_angle_to(to_global(pathfollow.position)) + 1.571)
		mario.velocity = dif
		var direction = Vector2(pathfollow.position.x - mario.position.x, pathfollow.position.y - mario.position.y)
		direction = direction.normalized()
		mario.velocity = direction * speed * 100
		mario.velocity = dif * 30
		mario.last_position = mario.position
		mario.rotation = 0
		
func cancel_launch(new, old):
	print("cancelling")
	fly_noise_player.stop()
	state = states.IDLE
	pathfollow.offset = 100
	mario.disconnect("state_changed", self, "cancel_launch")

