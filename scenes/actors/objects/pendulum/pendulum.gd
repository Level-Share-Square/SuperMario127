extends GameObject

onready var pivot = $"%Pivot"

var amplitude: float = 1
var angular_velocity: float = 1
var physics: bool = true
var time: float = 0

var rotation_offset: float = 0

#func _set_properties():
#	savable_properties = ["amplitude", "angular_velocity", "physics"]
#	editable_properties = ["amplitude", "angular_velocity", "physics"]

func _register_properties():
	register_property(4, "amplitude", amplitude, true)
	register_property(5, "angular_velocity", angular_velocity, true)
	register_property(6, "physics", physics, true)

func _object_ready():
	rotation_offset = rotation
	get_node("%CollisionShape2D").disabled = !enabled
	
func _object_physics_process(delta):
	._object_physics_process(delta)
	if !physics: return
	
	time += delta
	var angle: float = amplitude * cos(angular_velocity * time)
	
	rotation = angle + rotation_offset
