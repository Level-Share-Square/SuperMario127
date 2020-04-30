extends Decoration

func _init():
	chance_percentage = 25
	object_id = 11

func placement_check(tile, pos, noise, shared_node):
	return (
		tile == 2 
		and shared_node.get_objects_overlapping_position(Vector2(((pos.x - 1) * 32), (pos.y * 32) - 45)).size() <= 0 
		and shared_node.get_objects_overlapping_position(Vector2(((pos.x - 2) * 32), (pos.y * 32) - 45)).size() <= 0 
		and noise.get_noise_2d(pos.x - 2, pos.y) >= 0 
		and noise.get_noise_2d(pos.x - 2, pos.y - 1) <= 0 
		and noise.get_noise_2d(pos.x - 2, pos.y - 2) <= 0 
		and noise.get_noise_2d(pos.x - 1, pos.y) >= 0 
		and noise.get_noise_2d(pos.x - 1, pos.y - 1) <= 0 
		and noise.get_noise_2d(pos.x - 1, pos.y - 2) <= 0 
		and noise.get_noise_2d(pos.x, pos.y - 1) <= 0 
		and noise.get_noise_2d(pos.x, pos.y - 2) <= 0
	)

func get_placement_position(pos):
	return Vector2((pos.x * 32), (pos.y * 32) - 45)
