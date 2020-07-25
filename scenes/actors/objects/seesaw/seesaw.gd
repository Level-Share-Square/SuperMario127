extends GameObject

onready var body = $KinematicBody2D
onready var area = $KinematicBody2D/Area2D

var buffer := -5

var tilt := 0.0

var angular_velocity :=0

const HALF_PI = PI/2

export var player_influence : float = 0.02
export var back_factor : float = 0.02

func _ready():
	pass

func _physics_process(delta):
	if(mode==1):
		return
	
	var delta_rotation := 0
	for _body in area.get_overlapping_bodies():
		if(_body.get("prev_is_grounded") == true):
			var diff : float = _body.global_position.x-body.global_position.x
			
			delta_rotation += diff if _body.bottom_pos.global_position.y<(sin(tilt)*diff+body.global_position.y) else 0.0
		
	tilt -= tilt*back_factor
	
	tilt += delta_rotation * delta * player_influence
	
	
	tilt = clamp(tilt, -HALF_PI, HALF_PI)
		
	rotation = tilt
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
