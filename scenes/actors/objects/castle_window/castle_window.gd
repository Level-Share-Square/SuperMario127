extends GameObject


var is_background = false
export(Array, Texture) var palette_textures


func _set_properties():
	savable_properties = ["is_background"]


func _set_property_values(): 
	set_property("is_background", is_background, true)


func _ready():
	
	if palette != 0:
		self.texture = palette_textures[palette - 1]
