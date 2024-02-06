extends GameObject

var speed = 10

onready var path : Path2D = $Path2D
onready var pathfollow = $Path2D/PathFollow2D
var curve = Curve2D.new()
var custom_path = Curve2D.new()

onready var player_detector = $PlayerDetector

enum states {IDLE, HOLDING, LAUNCH}
var state = states.IDLE
var mario : Character
var old_gravity_scale = 1.0
#amount of time mario stays floating in the launch star before being dropped
var float_timer = 4
var momentum = 0
var last_position

func _set_properties():
	savable_properties = ["curve", "custom_path", "speed"]
	editable_properties = ["custom_path", "speed"]

func _set_property_values():
	set_property("curve", curve)
	set_property("custom_path", curve)
	set_property("speed", speed)

func invalid_curve(check : Curve2D):
	print(is_instance_valid(check))
	print(check.get_point_count())
	print(check.get_baked_points())
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
		
#	if(invalid_curve(curve) and invalid_curve(path.curve)):
#		print("one")
#		path.curve.add_point(Vector2(0,0))
#		path.curve.add_point(Vector2(0, -64))
#		curve = path.curve
#	elif(invalid_curve(curve)):
#		path.curve.add_point(Vector2(0,0))
#		path.curve.add_point(Vector2(0, -64))
#		curve = path.curve
#	# should never run
#	else:
#		print("three")
#		path.curve = curve
		
	last_position = position
		
func _process(_delta):
	if curve != path.curve:
		path.curve = curve
		
func _physics_process(delta):
	
	if(is_instance_valid(mario)):
		print(momentum)
	
	if enabled and mode == 0:
		match(state):
			states.IDLE:
				physics_process_idle(delta)
			states.HOLDING:
				physics_process_holding(delta)
			states.LAUNCH:
				physics_process_launch(delta)

# the launch star is waiting for mario to enter it
func physics_process_idle(delta:float):
	for body in player_detector.get_overlapping_bodies():
		if body.name.begins_with("Character"):
			#this is what lets mario fall
			if float_timer > 0:
				mario = body
				mario.set_state_by_name("LaunchStarState", delta)
				state = states.HOLDING
			return
	float_timer = 3
# the launch star is holding mario waiting for him to spin
func physics_process_holding(delta:float):
	mario.velocity = Vector2(0,0)
	float_timer -= delta
	if(float_timer <= 0):
		state = states.IDLE
		mario.set_state_by_name("FallState", delta)
		return
	mario.position = lerp(mario.position, position, 0.1)
	if mario.inputs[4][0]:
		state = states.LAUNCH
		return
		
		
# the launch star is launching mario
func physics_process_launch(delta:float):
	pathfollow.offset += speed
	
	momentum = (pathfollow.position - last_position) / (fps_util.PHYSICS_DELTA * 2)
	
	last_position = pathfollow.position
	
	if(mario.rotation_degrees != pathfollow.rotation_degrees + 90):
		mario.rotation = lerp_angle(mario.rotation, pathfollow.rotation + 1.571, speed / 200.0)
	mario.position = lerp(mario.position, position + pathfollow.position, 0.05)

	
	# reached end
	if pathfollow.offset >= path.curve.get_baked_length():
		state = states.IDLE
		mario.set_state_by_name("JumpState", delta)
		mario.jump_animation = 2
		mario.facing_direction = sign(momentum.x)
		mario.velocity = Vector2(cos(mario.rotation), sin(mario.rotation)) * speed
		mario.velocity = momentum * 10*speed/(speed*speed)
		mario.last_position = mario.position
		mario.rotation = 0
		pathfollow.offset = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
