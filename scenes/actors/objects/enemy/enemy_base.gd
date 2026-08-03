## should be the child of an EnemySpawnerBase node
class_name EnemyBase
extends KinematicBody2D


signal state_changed(new_state)

const UP_DIR := Vector2.UP
const SNAP_VECTOR := Vector2(0, 12)
const FLOOR_MAX_ANGLE: float = deg2rad(67)

# the enemy cant fall faster than gravity times this
export var max_gravity_factor: float = 20

export var facing_direction: int = -1
export var velocity: Vector2
export var cur_state: String

export var float_in_liquids: bool
export var float_speed: float = 32
export var float_accel: float = 4

var level_bounds: Rect2
# parent should set this to area gravity times two
var gravity: float
# if not is_enabled_and_on_ground()... enemy stops moving altogether (also used for editor)
var enabled: bool
# for wind
var snap_enabled: bool = true
# whether to emit particles on startup
var spawn_effect: bool = true
# layer ref
var layer_ref: WeakRef

# water and lava
onready var liquids_detector: Area2D = $LiquidsDetector
# detects platforms (copy pasted from mario.gd so we're just going to reuse this from there)
onready var platform_detector: Area2D = $PlatformDetector
# checks for the floor bc is_on_floor() is way too janky on it's own.
onready var floor_detector: RayCast2D = $FloorDetector
# holds all the states
onready var state_container: Node = $States 
# self explanatory
onready var sprite: AnimatedSprite = $AnimatedSprite
# checks for nearby dialogue triggers when disabled
onready var dialogue_detector: Area2D = $AnimatedSprite/DialogueDetector
# emits when spawned
onready var spawn_particles: Particles2D = $SpawnParticles
#bottom pos so platforms don't explode
onready var bottom_pos: Node2D = $BottomPos

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


func _ready():
	z_as_relative = true
	if spawn_effect:
		spawn_particles.emitting = true
	
	if enabled:
		dialogue_detector.initialize()
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
	if not float_in_liquids or liquids_detector.get_overlapping_areas().empty():
		if not is_on_floor():
			velocity.y += gravity * gravity_multiplier * delta * 60
			velocity.y = min(velocity.y, gravity * max_gravity_factor)
	else:
		velocity.y = move_toward(velocity.y, -float_speed, float_accel * delta * 60)
		working_snap_vector = Vector2.ZERO
	
	var floor_normal: Vector2 = get_floor_normal()
	
	for body in platform_detector.get_overlapping_bodies():
		if body is PhysicsBody2D:
			if body.can_collide_with(self):
				remove_collision_exception_with(body)
				floor_detector.remove_exception(body)
			else:
				add_collision_exception_with(body)
				floor_detector.add_exception(body)
	
	if is_on_ceiling() and velocity.y < 0:
		velocity.y = -velocity.y
	
	velocity = move_and_slide_with_snap(velocity, 
		working_snap_vector if velocity.y >= 0 else Vector2.ZERO, 
		UP_DIR, true, 4, FLOOR_MAX_ANGLE)


func is_on_ground() -> bool:
	return floor_detector.is_colliding()


func create_coin(velocity: Vector2, offset: Vector2):
	var object = create_object(global_position + offset, 1, 0)
	object.set_property("physics", true)
	object.set_property("velocity", velocity)
	return object


func create_object(pos: Vector2, object_id: int, palette: int):
	var level_layer: LevelLayer = layer_ref.get_ref()
	
	return level_layer.add_object(
		ObjectData.new(
			ObjectMetadata.new(
				pos,
				object_id,
				palette
			)
		)
	)
