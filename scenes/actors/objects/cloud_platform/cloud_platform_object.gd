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

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 0:
				parts = 0
			set_property("parts", parts, true)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts, true)

func _process(delta):
	if parts != last_parts:
		platform.parts = parts
		platform.update_parts()
	last_parts = parts
