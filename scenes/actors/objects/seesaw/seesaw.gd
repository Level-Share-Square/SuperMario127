extends GameObject

onready var body = $KinematicBody2D
onready var area = $KinematicBody2D/Area2D

var buffer := -5

var tilt := 0.0

var rotation_speed := 0.0

const HALF_PI = PI/2

func _ready():
	pass

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
	body.rotation = 0 #necessary because godot

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
