extends Node2D
export var speed : int = 1

func _ready():
	for child in get_children():
		if child is AnimatedSprite:
			child.frame = 0
			child.speed_scale = 1
			child.position = position
			if owner.is_preview:
				child.z_index = 0
				child.rotation_degrees = 0
func _process(delta):
	for child in get_children():
			if child is AnimatedSprite:
				child.speed_scale = speed
	
	

