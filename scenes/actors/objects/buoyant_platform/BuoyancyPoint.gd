extends Area2D


var shape_path := preload("res://scenes/actors/objects/buoyant_platform/BuoyancyShape.tscn")



func add_collision_shapes(parts, part_width):
	
	part_width /= 2
	for i in range((parts + 1) * 2):
		create_shape(parts, part_width, Vector2(global_position.x + i * part_width - ((parts + 0.5) * 2) * part_width/2, global_position.y + part_width/4))
		create_shape(parts, part_width, Vector2(global_position.x + i * part_width - ((parts + 0.5) * 2) * part_width/2, global_position.y - part_width/4))
		
func create_shape(parts: int, part_width: float, position: Vector2):
	var shape = shape_path.instance()
	shape.shape.radius = part_width/4
	add_child(shape)
	shape.global_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
