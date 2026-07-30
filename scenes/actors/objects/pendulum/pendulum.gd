extends GameObject

onready var pivot = $"%Pivot"

var amplitude: float = 1
var angular_velocity: float = 1
var physics: bool = true
var time: float = 0

var rotation_offset: float = 0

func _set_properties():
	savable_properties = ["amplitude", "angular_velocity", "physics"]
	editable_properties = ["amplitude", "angular_velocity", "physics"]

func _set_property_values():
	set_property("amplitude", amplitude, true)
	set_property("angular_velocity", angular_velocity, true)
	set_property("physics", physics, true)

func _object_ready():
	rotation_offset = rotation

func _object_disabled_ready():
	._object_disabled_ready()
	get_node("%CollisionShape2D").disabled = true
	
func _object_physics_process(delta):
	._object_physics_process(delta)
	if !physics: return
	
	time += delta
	var angle: float = amplitude * cos(angular_velocity * time)
	
	rotation = angle + rotation_offset
