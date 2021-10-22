extends GameObject

onready  var recolorable = $Recolorable

export  var custom_preview_position = Vector2(70, 170)
export (Array, Texture) var palette_textures

var color: = Color(0.972, 0.5, 0.16)

func _set_properties():
	savable_properties = ["color"]
	editable_properties = ["color"]
	
func _set_property_values():
	set_property("color", color, true)

func _ready():
	preview_position = custom_preview_position
	if color == Color(1, 0, 0):
		color = Color(0.972, 0.5, 0.16)
		if mode == 1:
			_set_property_values()
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0
	
	if palette != 0:
		$Sprite.texture = palette_textures[palette - 1]

func _process(delta):
	if color == Color(0.972, 0.5, 0.16):
		recolorable.visible = false
	else :
		recolorable.visible = true
		recolorable.self_modulate = color
