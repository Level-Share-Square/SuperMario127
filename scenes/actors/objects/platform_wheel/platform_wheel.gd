extends GameObject

var platforms := []
var delta_angle := PI/2
var time_alive := 0.0

var parts := 4
var last_parts := 4

var radius : float = 2

var speed : float = 2

func _set_properties():
	savable_properties = ["parts", "speed", "radius"]
	editable_properties = ["parts", "speed", "radius"]
	
func _set_property_values():
	set_property("parts", parts)
	set_property("speed", speed)
	set_property("radius", radius)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and hovered:
		if event.button_index == 5: # Mouse wheel down
			parts -= 1
			if parts < 1:
				parts = 1
			set_property("parts", parts)
		elif event.button_index == 4: # Mouse wheel up
			parts += 1
			set_property("parts", parts)

func _process(_delta):
	if parts != last_parts:
		for platform in platforms:
			platform.set_parts(parts)

# Called when the node enters the scene tree for the first time.
func _ready():
	var scene := load("res://scenes/actors/objects/touch_lift_platform/touch_lift_platform.tscn")
	
	for _i in range(4):
		var instance = scene.instance()
		platforms.append(instance)
		add_child(instance)

func _physics_process(delta):
	time_alive += delta * speed
	var angle := fmod(time_alive, (2*PI))
	for platform in platforms:
		if(mode!=1):
			platform.set_position(Vector2(radius * 32, 0).rotated(angle))
		else:
			platform.position = Vector2(radius * 32, 0).rotated(angle)
		angle += delta_angle
