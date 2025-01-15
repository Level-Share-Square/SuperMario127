extends AudioStreamPlayer2D


var last_saw_playback_pos : float = 0.0

func handle_saw_sound_position(screen_rect : Rect2):
	if get_tree().get_nodes_in_group("sawblades").size() <= 0: return
	
	var working_distance : float = screen_rect.get_center().distance_to(get_tree().get_nodes_in_group("sawblades")[0].global_position)
	
	var blasters_in_range : int = 0
	
	var new_pos : Vector2 = get_tree().get_nodes_in_group("sawblades")[0].global_position
	
	for saw in get_tree().get_nodes_in_group("sawblades"):
		var distance : float = screen_rect.get_center().distance_to(saw.global_position)
		
		if screen_rect.has_point(saw.global_position):
			if !playing:
				play()
			
			blasters_in_range += 1
			# if the new distance is smaller than the old one then set audio player's position to the closer position
			if distance < working_distance:
				new_pos = lerp(global_position, saw.global_position, .15)
				global_position = new_pos
	
	volume_db = min(blasters_in_range*1.45, 5)
	
	
	if last_saw_playback_pos > get_playback_position():
		set_random_saw_pitch()
	
	last_saw_playback_pos = get_playback_position()

func set_random_saw_pitch():
	pitch_scale = rand_range(0.97, 1.03)
#	print(saw_sound.pitch_scale)

func _draw():
	draw_circle(global_position, 5, Color.red)
