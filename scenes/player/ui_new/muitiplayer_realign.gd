extends CanvasLayer

func _ready():
	if Singleton.PlayerSettings.number_of_players != 2:
		return
	
	for child in get_children():
		child.rect_position.x -= (768/2)
