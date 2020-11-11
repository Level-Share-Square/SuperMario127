extends GameObject

var is_background = false

func _set_properties():
	savable_properties = ["is_background"]
	editable_properties = ["is_background"]

func _set_property_values(): 
	set_property("is_background", is_background, true)

func _process(delta):
	if is_background:
		$Sprite.self_modulate = Color(0.55, 0.55, 0.55) 
		z_index = -2
	else:
		$Sprite.self_modulate = Color(1, 1, 1) 
		z_index = 2
