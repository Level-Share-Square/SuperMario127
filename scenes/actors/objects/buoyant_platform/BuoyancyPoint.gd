extends Area2D


var shape_path := preload("res://scenes/actors/objects/buoyant_platform/BuoyancyShape.tscn")



func add_collision_shapes(length):
	var shape_size = shape_path.instance().shape.radius * 2

	for i in range(length/shape_size + 1):
		var shape = shape_path.instance()
		add_child(shape)
		shape.global_position = global_position
		shape.position.x = (-length/2) + i * shape_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
