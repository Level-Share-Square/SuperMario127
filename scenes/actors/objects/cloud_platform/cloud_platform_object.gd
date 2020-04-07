extends GameObject

onready var platform = $CloudPlatform

var parts := 1
var last_parts := 1

func _set_properties():
	savable_properties = ["parts"]
	editable_properties = ["parts"]
	
func _set_property_values():
	set_property("parts", parts, 1)
	if platform != null:
		platform.parts = parts
		platform.update_parts()
	else:
		yield(self, "ready")
		platform.parts = parts
		platform.update_parts()

func ready():
	preview_position = Vector2(0, 92)

func _process(delta):
	if parts != last_parts:
		platform.parts = parts
		platform.update_parts()
	last_parts = parts
