extends GameObject




func _on_Area2D_area_entered(area):

	if area == area.name.begins_with("Character"):
		#if water_in_sponge < max_water:
		  #player.water -= water_drain_speed
		  #water_in_sponge += water_drain_speed
		print(area.name.begins_with("Character"))
