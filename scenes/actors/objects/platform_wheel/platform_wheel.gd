extends GameObject

var platforms : Array = []
var delta_angle := PI/2
var time_alive := 0.0

var parts := 4
var last_parts := 4

var radius : float = 2

var speed : float = 2

var platform_count := 4

func _set_properties():
	savable_properties = ["parts", "speed", "radius", "platform_count"]
	editable_properties = ["parts", "speed", "radius", "platform_count"]
	
func _set_property_values():
	set_property("parts", parts)
	set_property("speed", speed)
	set_property("radius", radius)
	set_property("platform_count", platform_count)

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
		last_parts = parts
	
	if platform_count!=platforms.size():
		if platform_count>platforms.size():
			var scene := load("res://scenes/actors/objects/touch_lift_platform/touch_lift_platform.tscn")
			
			var delta_count = platform_count-platforms.size()
			for _i in range(delta_count):
				var instance = scene.instance()
				platforms.append(instance)
				add_child(instance)
				
		elif platform_count<platforms.size():
			var delta_count = platforms.size() - platform_count
			for _i in range(delta_count):
				remove_child(platforms.pop_back())
				
		delta_angle = (PI * 2) / platform_count

# Called when the node enters the scene tree for the first time.
func _ready():
	var scene := load("res://scenes/actors/objects/touch_lift_platform/touch_lift_platform.tscn")
	
	for _i in range(platform_count):
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
