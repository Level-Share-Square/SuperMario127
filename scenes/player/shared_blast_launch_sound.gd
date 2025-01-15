extends AudioStreamPlayer2D


func handle_blast_sound_position(listener_position : Vector2):
	if get_tree().get_nodes_in_group("blasters").size() <= 0: return
	
	var working_distance = null #pog dynamic typing :D
	
	var blasters_in_range : int = 0
	for blaster in get_tree().get_nodes_in_group("blasters"):
		var distance : float = listener_position.distance_to(blaster.global_position)
		
		if distance <= max_distance/2:
			
			blasters_in_range += 1
			# if the new distance is smaller than the old one then set audio player's position to the closer position
			if working_distance != null:
				if distance < working_distance:
					global_position = lerp(global_position, blaster.global_position, .15)
					working_distance = distance
			else:
				global_position = lerp(global_position, blaster.global_position, .15)
				working_distance = distance
		
	volume_db = min(blasters_in_range*1.45, 5)

func _draw():
	draw_circle(global_position, 5, Color.red)
