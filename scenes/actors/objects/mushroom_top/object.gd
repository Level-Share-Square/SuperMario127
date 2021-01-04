extends GameObject

export var custom_preview_position = Vector2(70, 170)

var color := Color(1, 0, 0)

func _set_properties():
	savable_properties = ["color"]
	editable_properties = ["color"]
	
func _set_property_values():
	set_property("color", color, 1)

func _ready():
	preview_position = custom_preview_position
	if is_preview:
		z_index = 0
		$Sprite.z_index = 0

func _process(delta):
	if color == Color(1, 0, 0):
		$Color.visible = false
	else:
		$Color.visible = true
		$Color.modulate = color
