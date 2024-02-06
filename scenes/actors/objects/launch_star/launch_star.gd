extends GameObject

var speed = 3

onready var path : Path2D = $Path2D
onready var pathfollow = $Path2D/PathFollow2D
var curve = Curve2D.new()
var custom_path = Curve2D.new()

onready var player_detector = $PlayerDetector

enum states {IDLE, HOLDING, LAUNCH}
var state = states.IDLE
var mario : Character
var old_parent
#amount of time mario stays floating in the launch star before being dropped
var float_timer = 4

func _set_properties():
	savable_properties = ["custom_path", "speed"]
	editable_properties = ["custom_path", "speed"]

func _set_property_values():
	set_property("custom_path", curve)
	set_property("speed", speed)

func valid_curve(check : Curve2D):
	if(is_instance_valid(check) and check.get_point_count() > 0):
		return true
	else:
		return false
		

func _ready():
	# first creation of object
	if(!valid_curve(curve) and !valid_curve(path.curve)):
		path.curve.add_point(Vector2(0,0))
		path.curve.add_point(Vector2(0,-200))
		path.curve.add_point(Vector2(200,-400))
		path.curve.add_point(Vector2(600,-300))
	elif(!valid_curve(curve)):
		curve = path.curve
	# should never run
	else:
		path.curve = curve
		
func _process(_delta):
	if curve != path.curve:
		path.curve = curve
		
func _physics_process(delta):
	
		#print(state)
	
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
	float_timer -= delta
	if(float_timer <= 0):
		state = states.IDLE
		mario.set_state_by_name("FallState", delta)
		return
	mario.position = position
	if mario.inputs[4][0]:
		state = states.LAUNCH
		return
		
		
# the launch star is launching mario
func physics_process_launch(delta:float):
	pathfollow.offset += speed
	mario.position = position + pathfollow.position
	mario.rotation = pathfollow.rotation + 90

	# reached end
	if pathfollow.offset >= path.curve.get_baked_length():
		state = states.IDLE
		mario.set_state_by_name("FallState", delta)
		mario.rotation = 0
		pathfollow.offset = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
