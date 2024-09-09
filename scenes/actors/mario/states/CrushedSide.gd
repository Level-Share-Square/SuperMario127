class_name CrushedSideState
extends CrushedBaseState

const PAINFUL_SCALE_THRESHOLD: float = 0.5

export var left_check_path: NodePath
export var right_check_path: NodePath

onready var left_check: RayCast2D = get_node(left_check_path)
onready var right_check: RayCast2D = get_node(right_check_path)

func _ready():
	blacklisted_states = ["CrushedState", "SlideStopState"]

func _is_squished() -> bool:
	return left_check.is_colliding() and right_check.is_colliding()

func _past_squish_threshold() -> bool:
	var sprite = character.sprite
	return sprite.scale.x < PAINFUL_SCALE_THRESHOLD


func _start(_delta):
	._start(_delta)
	character.collision_raycast.disabled = true

func _update(delta):
	# calls update in the base class
	._update(delta)
	
	var left_point: float = get_ray_point(left_check).x
	var right_point: float = get_ray_point(right_check).x
	var length: float = abs(left_point) + abs(right_point)
	var total_length: float = abs(left_check.cast_to.x) + abs(right_check.cast_to.x)

	var sprite = character.sprite
	sprite.scale.x = max(length / total_length, MIN_SPRITE_SCALE)

func _stop(_delta):
	._stop(_delta)
	character.collision_raycast.disabled = false


func _general_update(_delta):
	# lets make sure mario doesnt get stuck
	if left_check.is_colliding():
		character.position.x += 1
	if right_check.is_colliding():
		character.position.x -= 1
