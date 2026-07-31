extends ResizableSemisolid


var color := Color(1, 1, 1)


#func _set_properties():
#	savable_properties = ["parts", "color"]
#	editable_properties = ["parts", "color"]


func _register_properties():
	register_property(4, "parts", parts, true)
	register_property(5, "color", color, 1)


func _process(delta):
	sprite.modulate = color
