extends GameObject

onready var body = $KinematicBody2D
onready var area = $KinematicBody2D/Area2D

var buffer := -5

var tilt := 0.0

var rotation_speed := 0.0

const HALF_PI = PI/2

export var player_influence : float = 0.01
export var back_factor : float = 0.02

func _ready():
	pass

#code *cough" stolen *cough* from sm63
func friction(a,b,c):
	var d
	if(a > 0):
		d = 1
	else:
		d = -1
	a = abs(a)
	a = a - b
	if(a < 0):
		a = 0
	a = a / c;
	a = a * d;
	return a;

#func _process(delta):
#	if(mode==1):
#		return
#
#	rotation_speed = friction(rotation_speed,0.15,1.05)
#
#	var scale_x = scale.x
#	var weight_rotation_speed := 0.0
#	for _body in area.get_overlapping_bodies():
#		if(_body.get("prev_is_grounded") == true):
#			var diff : float = _body.global_position.x-body.global_position.x/scale_x
#
#			weight_rotation_speed += (diff / 5 / ((scale_x - 1) / 2 + 1)) if _body.bottom_pos.global_position.y<(sin(tilt)*diff+body.global_position.y) else 0.0
#
#	if(weight_rotation_speed!=0):
#		rotation_speed += weight_rotation_speed
#		rotation_speed -= (tilt - friction(tilt,0.3 / scale_x,0.07 / scale_x + 1))
#	else:
#		rotation_speed -= (tilt - friction(tilt,1 / scale_x,0.12 / scale_x + 1))
#
#	tilt += rotation_speed / 20
#	if(tilt >= 80 || tilt <= -80):
#		rotation_speed *= -0.7
#
#	tilt = max(tilt,-80)
#	tilt = min(tilt,80)
#	var a = 1
#	rotation_degrees = round(tilt) * a + rotation_degrees * (1-a)
#	body.rotation = 0
	

func _physics_process(delta):
	if(mode==1):
		return
	
	var scale_x = scale.x
	
	var delta_rotation := 0
	for _body in area.get_overlapping_bodies():
		var bottom_pos = _body.get("bottom_pos")
		if(bottom_pos):
			var diff : float = _body.global_position.x-body.global_position.x
			
			var distance = (tan(tilt)*diff+body.global_position.y) - bottom_pos.global_position.y - 5 * scale.y
			if(distance>0):
				print(distance)
			var factor = max(0,1-distance/10) / scale_x
			
			var weight := 1.0
			if _body.has_method("get_weight"):
				weight = _body.get_weight()
			
			delta_rotation += (diff * factor) * weight if distance>0 else 0.0


	tilt += clamp(delta_rotation,-70,70) * delta * 0.05

	rotation_speed -= tilt*delta*0.25

	rotation_speed *= pow(0.92,delta*60)
	tilt = clamp(tilt + rotation_speed, -HALF_PI, HALF_PI)


	rotation = tilt
	tilt = rotation
	body.rotation = 0

func can_collide_with(character):
	var direction = body.global_transform.y.normalized()
	
	# Use prev_is_grounded because calling is_grounded() is broken
	var is_grounded = character.prev_is_grounded if character.get("prev_is_grounded") != null else true
	# Some math that gives us useful vectors
	var line_center = body.global_position + (direction * buffer)
	var line_direction = Vector2(-direction.y, direction.x)
	var p1 = line_center + line_direction
	var p2 = line_center - line_direction
	var p = character.bottom_pos.global_position #if is_grounded else character.global_position
	#var velocity = character.velocity if character.get("velocity") != null else Vector2(0, 0) seems to be unused, uncomment if needed
	var diff = p2 - p1
	var perp = Vector2(-diff.y, diff.x)
	
	if !is_grounded:
		# If in the air, check for the velocity first
		# If we're trying to pass through it from the other way around,
		# cancel it
		var d = character.velocity.dot(perp)
		if d < 0:
			return false
		
		# In both cases, a threshold is applied that prevents clips
		p -= character.velocity.normalized()
	else:
		p -= perp
	
	# Is p on the correct side?
	var d = (p - p1).dot(perp)
	return sign(d) != 1
