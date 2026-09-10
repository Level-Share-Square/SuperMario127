extends GameObject


export(Array, Texture) var palette_textures


func _ready():
	var _connect = connect("property_changed", self, "update_property")
	update_property("palette", palette)


func update_property(key: String, value):
	if key == "palette":
		$Sprite.texture = palette_textures[value]


func _object_ready():
	._object_ready()
	$StaticBody2D.set_collision_layer_bit(0, is_enabled_and_on_ground())
