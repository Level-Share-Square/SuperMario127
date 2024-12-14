## should be the child of an EnemySpawnerBase node
class_name EnemyBase
extends KinematicBody2D


signal state_changed(new_state)

const UP_DIR := Vector2.UP
const SNAP_VECTOR := Vector2(0, 12)
const FLOOR_MAX_ANGLE: float = rad2deg(67)

# the enemy cant fall faster than gravity times this
export var max_gravity_factor: float = 20

export var facing_direction: int = -1
export var velocity: Vector2
export var cur_state: String

export var float_in_liquids: bool
export var float_speed: float = 32
export var float_accel: float = 4

# parent should set this to area gravity times two
var gravity: float
# if not enabled... enemy stops moving altogether (also used for editor)
var enabled: bool
# for wind
var snap_enabled: bool = true

# water and lava
onready var liquids_detector: Area2D = $LiquidsDetector
# holds all the states
onready var state_container: Node = $States 
# self explanatory
onready var sprite: AnimatedSprite = $AnimatedSprite
# what the enemys currently doing
var state: EnemyState
# inflicting and receiving damage
var damage: EnemyDamage


func get_state_by_name(state_name: String) -> EnemyState:
	return state_container.get_node_or_null(state_name) as EnemyState


func set_state_by_name(state_name: String) -> void:
	set_state_node(get_state_by_name(state_name))


func set_state_node(new_state: EnemyState) -> void:
	if new_state == state: return
	
	if is_instance_valid(state) and enabled:
		state._stop()
	state = new_state
	emit_signal("state_changed", new_state)
	if is_instance_valid(new_state) and enabled:
		new_state._start()


func initialize():
	if enabled:
		set_state_by_name(cur_state)
		if float_in_liquids:
			liquids_detector.monitoring = true


func _physics_process(delta):
	if not enabled: return
	
	sprite.flip_h = (facing_direction > 0)
	
	var working_snap_vector: Vector2 = SNAP_VECTOR if snap_enabled else Vector2.ZERO
	var gravity_multiplier: float = 1
	if is_instance_valid(state):
		state._update(delta)
		gravity_multiplier *= state.gravity_multiplier
	
	# gravity and floating in liquids
	if not float_in_liquids or liquids_detector.get_overlapping_areas().size() <= 0:
		velocity.y += gravity * gravity_multiplier * delta * 60
		velocity.y = min(velocity.y, gravity * max_gravity_factor)
	else:
		velocity.y = move_toward(velocity.y, -float_speed, float_accel * delta * 60)
		working_snap_vector = Vector2.ZERO
	
	var floor_normal: Vector2 = get_floor_normal()
	var working_velocity = velocity
	
	# counteract slope slowdown/speedup
	if is_on_floor() and not is_zero_approx(floor_normal.y):
		# anti-slowdown
		if sign(floor_normal.x) != sign(working_velocity.x):
			working_velocity.x /= abs(floor_normal.y)
		# anti-speedup
		else:
			working_velocity.x *= abs(floor_normal.y)
	
	velocity.y = move_and_slide_with_snap(working_velocity, working_snap_vector, UP_DIR, false, 4, FLOOR_MAX_ANGLE).y
