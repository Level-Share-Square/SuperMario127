class_name CrushedState
extends CrushedBaseState

const SPRITE_SCALE_FACTOR: int = 24
const PAINFUL_SCALE_THRESHOLD: float = 0.3

export var vertical_check_path: NodePath
export var vertical_check_dive_path: NodePath

onready var vertical_check: RayCast2D = get_node(vertical_check_path)
onready var vertical_check_dive: RayCast2D = get_node(vertical_check_dive_path)

func _ready():
	blacklisted_states = ["CrushedSideState", "SlideStopState"]

func _is_squished() -> bool:
	return character.is_grounded() and get_vertical_check().is_colliding()

func _past_squish_threshold() -> bool:
	var sprite = character.sprite
	return sprite.scale.y < PAINFUL_SCALE_THRESHOLD

func get_vertical_check() -> RayCast2D:
	if character.using_dive_collision: return vertical_check_dive
	return vertical_check


func _update(delta):
	# calls update in the base class
	._update(delta)
	
	var vertical_point: float = get_ray_point(vertical_check).y
	var vertical_length: float = abs(vertical_check.cast_to.y)
	
	var sprite = character.sprite
	sprite.scale.y = max(abs(vertical_point) / vertical_length, MIN_SPRITE_SCALE)
	# i forgot sprite offset was affected by its scale... took me a while to figure out :p
	sprite.offset.y = (1 - sprite.scale.y) * (SPRITE_SCALE_FACTOR / sprite.scale.y)

func _stop_check(_delta):
	return not get_vertical_check().is_colliding()
