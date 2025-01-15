extends AudioStreamPlayer2D


func handle_blast_sound_position(screen_rect : Rect2):
	if get_tree().get_nodes_in_group("blasters").size() <= 0: return
	
	var working_distance : float = screen_rect.get_center().distance_to(get_tree().get_nodes_in_group("blasters")[0].global_position)
	
	var blasters_in_range : int = 0
	
	var new_pos : Vector2 = get_tree().get_nodes_in_group("blasters")[0].global_position
	
	for blaster in get_tree().get_nodes_in_group("blasters"):
		var distance : float = screen_rect.get_center().distance_to(blaster.global_position)
		
		if screen_rect.has_point(blaster.global_position):
			blasters_in_range += 1
			# if the new distance is smaller than the old one then set audio player's position to the closer position
			if distance < working_distance:
				new_pos = lerp(global_position, blaster.global_position, .15)
				global_position = new_pos
	
	volume_db = min(blasters_in_range*1.45, 5)

func _draw():
	draw_circle(global_position, 5, Color.green)
