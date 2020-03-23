extends GameObject

func _ready():
	if mode == 0:
		var player = get_tree().get_current_scene()
		var character = player.get_node(player.character)
		var character2 = player.get_node(player.character2)
		character.position = position
		character2.position = position + Vector2(16, 0)
