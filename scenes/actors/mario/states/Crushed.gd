class_name CrushedState
extends CrushedBaseState


const PAINFUL_SCALE_THRESHOLD: float = 0.5

export var detector_path: NodePath
export var pain_path: NodePath

onready var crushed_detector: Area2D = get_node(detector_path)
onready var pain_detector: Area2D = get_node(pain_path)


func _ready():
	blacklisted_states = ["SlideStopState"]

func _is_squished() -> bool:
	return character.predictive_collision and crushed_detector.get_overlapping_bodies().size() > 1

func _past_squish_threshold() -> bool:
	return pain_detector.get_overlapping_bodies().size() > 0


func _start(_delta):
	._start(_delta)
	#character.collision_raycast.disabled = true

func _update(delta):
	# calls update in the base class
	._update(delta)
	
	## TODO: real animation
	character.sprite.scale = Vector2(1, 0.1)
	character.sprite.rotation = 0
	#var left_point: float = get_ray_point(left_check).x
	#var right_point: float = get_ray_point(right_check).x
	#var length: float = abs(left_point) + abs(right_point)
	#var total_length: float = abs(left_check.cast_to.x) + abs(right_check.cast_to.x)

	#var sprite = character.sprite
	#sprite.scale.x = max(length / total_length, MIN_SPRITE_SCALE)

func _stop(_delta):
	._stop(_delta)
	#character.collision_raycast.disabled = false
