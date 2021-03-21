extends GameObject

onready var sprite = $Sprite
onready var sprite2 = $Sprite/Sprite2

var color := Color(1, 1, 1)

func _set_properties():
	savable_properties = ["color"]
	editable_properties = ["color"]
	
func _set_property_values():
	set_property("color", color, true)

func _process(delta):
	sprite.self_modulate = color
