extends GameObject

var show_behind_layer := false

func _set_properties():
	savable_properties = ["show_behind_layer"]
	editable_properties = ["show_behind_layer"]

func _ready():
	if mode == 0:
		if enabled:
			var player = get_tree().get_current_scene()
			var character = player.get_node(player.character)
			character.position = position
			character.spawn_pos = position
			character.get_node("Spotlight").enabled = show_behind_layer
			character.scale = scale
			character.visible = visible
