extends AudioStreamPlayer2D


var last_saw_playback_pos : float = 0.0

func handle_saw_sound_position(listener_position : Vector2):
	if get_tree().get_nodes_in_group("sawblades").size() <= 0: return
	
	var working_distance = null #pog dynamic typing :D
	
	var saws_in_range : int = 0
	for saw in get_tree().get_nodes_in_group("sawblades"):
		var distance : float = listener_position.distance_to(saw.global_position)
		
		if distance <= max_distance/2:
			if !playing:
				play()
			
			saws_in_range += 1
			# if the new distance is smaller than the old one then set audio player's position to the closer position
			if working_distance != null:
				if distance < working_distance:
					global_position = lerp(global_position, saw.global_position, .15)
					working_distance = distance
			else:
				global_position = lerp(global_position, saw.global_position, .15)
				working_distance = distance
		
	volume_db = min(saws_in_range*1.45, 5)
	
	if last_saw_playback_pos > get_playback_position():
		set_random_saw_pitch()
	
	last_saw_playback_pos = get_playback_position()

func set_random_saw_pitch():
	pitch_scale = rand_range(0.97, 1.03)
#	print(saw_sound.pitch_scale)
