extends GameObject

onready var pivot = $"%Pivot"

var angle: float = 90
var speed: float = 5
var physics: bool = true
var time: float = 0

var angular_velocity: float = 0
var rotation_offset: float = 0
var rotation_angle: float = 0

#func _set_properties():
#	savable_properties = ["amplitude", "angular_velocity", "physics"]
#	editable_properties = ["amplitude", "angular_velocity", "physics"]

func _register_properties():
	register_property(4, "speed", speed, true)
	register_property(5, "angle", angle, true)
	register_property(6, "physics", physics, true)
	
func _ready():
	reset_physics_state()
	
func _editor_ready():
	._editor_ready()
	self_modulate.a = 0.2
	connect("property_changed", self, "on_property_changed")

func _object_ready():
	self_modulate.a = 1
	get_node("%CollisionShape2D").disabled = !enabled
	
func _physics_process(delta):
	if !physics: return
	var angular_acceleration = -(speed) * sin(rotation_angle)
	
	angular_velocity += angular_acceleration * delta
	rotation_angle += angular_velocity * delta
	
	rotation = rotation_angle + rotation_offset
	
func on_property_changed(key, value):
	if key == "rotation_degrees":
		rotation_offset = value
	reset_physics_state()

func reset_physics_state():
	rotation_angle = 0
	angular_velocity = sqrt(2 * speed * (1 - cos(deg2rad(angle))))
	rotation = rotation_offset
