extends GameObject

var oscillating := false
var power := 5.0
var speed := 5.0

var original_position : Vector2
var time = 0.0

func _set_properties():
	savable_properties = ["oscillating", "power", "speed"]
	editable_properties = ["oscillating", "power", "speed"]

func _set_property_values():
	set_property("oscillating", oscillating)
	set_property("power", power)
	set_property("speed", speed)

func _ready():
	original_position = global_position

func _physics_process(delta):
	if mode != 1:
		time += delta
		global_position.y = original_position.y + (sin(time*speed)*power)
