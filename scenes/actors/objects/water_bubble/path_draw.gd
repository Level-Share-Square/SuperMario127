tool
extends Area2D

export var radius = 500 setget set_radius

func set_radius(value):
	radius = value
	_ready()

func _ready():
	var arr = []
	arr.resize(int(.1 * PI * radius) + 2)  # Point count = circle length / 200 + 2, tweak for different results
	var step = PI * 2 / (arr.size() - 1)
	
	for i in arr.size() - 1:
		arr[i] = Vector2(cos(step * i) * radius, sin(step * i) * radius)
	
	arr[arr.size() - 1] = Vector2(radius, 0)
	$"Line".points = PoolVector2Array(arr)
	$"Line".material.set_shader_param("x_size", 0.01*PI*(radius+15))
	$"Fill".polygon = PoolVector2Array(arr)
	$"Shape".shape.radius = radius
