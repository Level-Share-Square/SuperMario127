extends GameObject

var is_background = false
export(Array, Texture) var palette_textures

func _set_properties():
	savable_properties = ["is_background"]
	editable_properties = ["is_background"]

func _set_property_values(): 
	set_property("is_background", is_background, true)

func _process(delta):
	if is_background:
		self_modulate = Color(0.55, 0.55, 0.55) 
		z_index = -2 if !is_preview else 0
	else:
		self_modulate = Color(1, 1, 1) 
		z_index = 10 if !is_preview else 0

	if palette != 0:
		self.texture = palette_textures[palette - 1]
