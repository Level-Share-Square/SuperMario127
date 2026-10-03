extends Area2D


func get_player() -> Character:
	var bodies = get_overlapping_bodies()
	
	if bodies.size() <= 0:
		return null

	for body in bodies:
		if body is Character:
			var character: Character = body
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
