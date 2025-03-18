extends RigidBody2D

onready var collision = $CollisionShape2D
var shape
onready var test_ray = $RayCast2D


func _ready():
	shape = collision.shape
	inertia = 1000
	
func _integrate_forces(state):
	#if linear_velocity == Vector2.ZERO:
		#linear_velocity = Vector2(0, 98)
	print(applied_force)
	#applied_force = applied_force.normalized() * 200
	test_ray.cast_to = applied_force
	
