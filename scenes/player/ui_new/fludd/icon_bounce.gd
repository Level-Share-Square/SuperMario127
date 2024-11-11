extends Control


export var default_gravity: float
export var floaty_gravity: float
export var bounce_power: float
export var end_bounce_power: float
export var do_bounce: bool

var gravity: float
var velocity: float
var end_bounce_queued: bool


func _physics_process(delta):
	gravity = default_gravity if do_bounce else floaty_gravity
	
	velocity += gravity
	rect_position.y += velocity
	
	if rect_position.y >= 0:
		if do_bounce:
			velocity = -bounce_power
			
		elif end_bounce_queued:
			velocity = -end_bounce_power
			end_bounce_queued = false
			
		else:
			rect_position.y = 0
			velocity = 0
