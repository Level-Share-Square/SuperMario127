extends Node2D

func _ready():
	for child in get_children():
		if child is AnimatedSprite:
			child.frame = 0
	
func change_speed(to : float):
	for child in get_children():
			if child is AnimatedSprite:
				child.speed_scale = to
	

