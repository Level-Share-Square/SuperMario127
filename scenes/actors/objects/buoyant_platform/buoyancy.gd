extends RigidBody2D

const SINKING_FORCE : Vector2 = Vector2(0, 4.3)
onready var collision = $CollisionShape2D
onready var test_ray = $RayCast2D
onready var standing_detector = $"%CharacterStandingDetector"
onready var standing_detector_shape = $CharacterStandingDetector/CollisionShape2D

var shape
var buoyancy_point:= preload("res://scenes/actors/objects/buoyant_platform/BuoyancyPoint.tscn")
var point_area : Area2D
var num_shapes = 0
var can_sink : bool = false

var char_is_standng : bool = false

export var float_force : float = 270.0


func init_physics():
	shape = collision.shape
	var parent = get_parent()
	if parent.mode != 1 and parent.physics_enabled and parent.is_on_ground_layer():
		num_shapes = (parent.parts + 1) * 2
		sleeping = false
		point_area = buoyancy_point.instance()
		add_child(point_area)
		point_area.global_position = global_position
		point_area.add_collision_shapes(get_parent().parts, 32)
		inertia = 1000 + 100 * num_shapes
		point_area.connect("area_shape_entered", self, "buoyancy_point_submerged")
		point_area.connect("area_shape_exited", self, "buoyancy_point_surfaced")
		standing_detector.connect("body_entered", self, "character_standing")
		standing_detector.connect("body_exited", self, "character_leaving")
		
	else:
		mode = MODE_STATIC
		can_sink = false
	

func _integrate_forces(state):
	#if linear_velocity == Vector2.ZERO:
		#linear_velocity = Vector2(0, 98)
	#applied_force = applied_force.normalized() * 200
	linear_velocity.limit_length(300)
	test_ray.cast_to = applied_force
	
func buoyancy_point_submerged(area_rid: RID, area: Area, area_shape_index: int, local_shape_index: int):

	var local_shape_owner = point_area.shape_find_owner(local_shape_index)
	var local_shape_node = point_area.shape_owner_get_owner(local_shape_owner)
	var dif = local_shape_node.position
	add_force(dif, Vector2(0, -float_force/num_shapes))
	dif = local_shape_node.global_position - global_position
	linear_velocity += Vector2(rotation_degrees/90 * abs(dif.x) * 10, 0)/num_shapes
	#gravity_scale = 1
	pass
	
func buoyancy_point_surfaced(area_rid: RID, area: Area, area_shape_index: int, local_shape_index: int):

	var local_shape_owner = point_area.shape_find_owner(local_shape_index)
	var local_shape_node = point_area.shape_owner_get_owner(local_shape_owner)
	var dif = local_shape_node.global_position - global_position
	dif = local_shape_node.position
	add_force(dif, Vector2(0, float_force/num_shapes))
	#gravity_scale = 7
		
	
func _physics_process(delta: float) -> void:
	if !can_sink: return
	for body in standing_detector.get_overlapping_bodies():
		if body is Character and body.has_method("is_grounded") and !body.swimming and body.is_grounded():
			linear_velocity += SINKING_FORCE
			if is_instance_valid(body.powerup) and body.powerup.name == "MetalPowerup":
				linear_velocity += SINKING_FORCE/2
