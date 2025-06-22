extends Area2D


onready var sight_ray: RayCast2D = get_node("SightRay")


func get_player(use_sight_ray: bool = true) -> Character:
	var bodies = get_overlapping_bodies()
	
	if bodies.size() <= 0:
		sight_ray.enabled = false
		return null
		
	for body in bodies:
		if body is Character:
			sight_ray.enabled = use_sight_ray
			
			var character: Character = body
			
			if use_sight_ray:
				sight_ray.cast_to = sight_ray.to_local(body.global_position)
				
				if not sight_ray.is_colliding():
					return character
				else:
					return null
			
			return character
	
	return null


func get_player_from_world(valid_distance: Vector2) -> Character:
	var player = get_tree().current_scene
	var characters: Array = player.get_characters()
	
	var i: int = 0
	for character in characters:
		if (
			abs(character.global_position.x - global_position.x) > valid_distance.x or 
			abs(character.global_position.y - global_position.y) > valid_distance.y
			):
			characters.pop_at(i)
		
		i += 1
	
	return characters.pick_random()
