extends GameObject

func _ready():
	if mode == 0:
		var player = get_tree().get_current_scene()
		var character = player.get_node(player.character)
		character.position = position
		character.spawn_pos = position
	else:
		var object_settings = get_tree().get_current_scene().get_node(get_tree().get_current_scene().object_settings)
		object_settings.open_object(self)
