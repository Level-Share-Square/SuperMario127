extends RigidBody2D

onready var collision = $CollisionShape2D
onready var test_ray = $RayCast2D

var shape
var buoyancy_point:= preload("res://scenes/actors/objects/buoyant_platform/BuoyancyPoint.tscn")
var point_area : Area2D
var num_shapes = 0

export var float_force : float = 400.0


func _ready():
	shape = collision.shape
	var parent = get_parent()
	if parent.mode != 1 and parent.physics_enabled:
		num_shapes = parent.parts + 1
		sleeping = false
		point_area = buoyancy_point.instance()
		add_child(point_area)
		point_area.global_position = global_position
		point_area.add_collision_shapes(get_parent().parts, 32)
		inertia = 1000 + 100 * num_shapes
		point_area.connect("area_shape_entered", self, "buoyancy_point_submerged")
		point_area.connect("area_shape_exited", self, "buoyancy_point_surfaced")
		
	else:
		mode = MODE_STATIC
	
		
func _integrate_forces(state):
	#if linear_velocity == Vector2.ZERO:
		#linear_velocity = Vector2(0, 98)
#	print(applied_force)
	#applied_force = applied_force.normalized() * 200
	linear_velocity.limit_length(300)
	test_ray.cast_to = applied_force
	
func buoyancy_point_submerged(area_rid: RID, area: Area, area_shape_index: int, local_shape_index: int):

	var local_shape_owner = point_area.shape_find_owner(local_shape_index)
	var local_shape_node = point_area.shape_owner_get_owner(local_shape_owner)
	var dif = local_shape_node.position
	add_force(dif, Vector2(0, -float_force/num_shapes))
	dif = local_shape_node.global_position - global_position
	linear_velocity += Vector2(rotation_degrees/90 * abs(dif.x), 0)/num_shapes
	pass
	
func buoyancy_point_surfaced(area_rid: RID, area: Area, area_shape_index: int, local_shape_index: int):

	var local_shape_owner = point_area.shape_find_owner(local_shape_index)
	var local_shape_node = point_area.shape_owner_get_owner(local_shape_owner)
	var dif = local_shape_node.global_position - global_position
	dif = local_shape_node.position
	add_force(dif, Vector2(0, float_force/num_shapes))
		
	
