extends GameObject

var show_behind_player = true

func _set_properties():
	savable_properties = ["show_behind_player"]
	editable_properties = ["show_behind_player"]

func _set_property_values(): 
	set_property("show_behind_player", show_behind_player, true)

func _ready():
	preview_position = Vector2(70, 170)
	if show_behind_player: 
		z_index = -2
	else:
		z_index = 2
