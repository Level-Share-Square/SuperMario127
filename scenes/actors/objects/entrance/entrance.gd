extends GameObject

func _ready():
	if mode == 0:
		var player = get_tree().get_current_scene()
		var character = player.get_node(player.character)
		character.position = position
		character.spawn_pos = position
