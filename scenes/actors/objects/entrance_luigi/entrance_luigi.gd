extends GameObject

func _ready():
	if mode == 0:
		var player = get_tree().get_current_scene()
		var character2 = player.get_node(player.character2)
		character2.position = position
