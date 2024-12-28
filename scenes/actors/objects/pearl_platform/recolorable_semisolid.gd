extends ResizableSemisolid


var color := Color(1, 1, 1)


func _set_properties():
	savable_properties = ["parts", "color"]
	editable_properties = ["parts", "color"]


func _set_property_values():
	set_property("parts", parts, 1)
	set_property("color", color, 1)


func _process(delta):
	sprite.modulate = color
