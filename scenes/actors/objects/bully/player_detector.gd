extends Area2D


# Cast a ray from the position of the area to the position of whatever object may be in the area.
export var use_line_of_sight: bool = true

onready var sight_ray: RayCast2D = get_node("SightRay")


func get_player() -> Character:
	var bodies = get_overlapping_bodies()
	
	if bodies.size() <= 0:
		sight_ray.enabled = false
		return null
		
	for body in bodies:
		if body is Character:
			sight_ray.enabled = true
			
			var character: Character = body
			sight_ray.cast_to = sight_ray.to_local(body.global_position)
			
			if not sight_ray.is_colliding():
				return character
	
	return null
