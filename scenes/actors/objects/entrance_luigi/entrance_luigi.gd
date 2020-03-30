extends GameObject

var show_behind_layer := true

func _set_properties():
	savable_properties = ["show_behind_layer"]
	editable_properties = ["show_behind_layer"]

func _ready():
	if mode == 0:
		if enabled:
			var player = get_tree().get_current_scene()
			var character2 = player.get_node(player.character2)
			character2.position = position
			character2.spawn_pos = position
			character2.get_node("Spotlight").enabled = show_behind_layer
			character2.scale = scale
			character2.visible = visible
