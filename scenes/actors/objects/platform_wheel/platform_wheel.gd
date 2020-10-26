extends GameObject

var platforms : Array = []
var delta_angle := PI/2
var time_alive := 0.0

var parts := 4
var last_parts := 4

var color := Color.green
var last_color := Color.green

var start_angle := 0.0
onready var angle_offset := deg2rad(start_angle)

var radius : float = 2
var last_radius : float = 2

var speed : float = 2

var platform_count := 4

func _set_properties():
	savable_properties = ["parts", "speed", "radius", "platform_count", "color", "start_angle"]
	editable_properties = ["parts", "speed", "radius", "platform_count", "color", "start_angle"]
	
func _set_property_values():
	set_property("parts", parts)
	set_property("speed", speed)
	set_property("radius", radius)
	set_property("platform_count", platform_count)
	set_property("color", color)
	set_property("start_angle", start_angle)

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
				
				# Disable the collision if enabled = false
				instance.collision_shape.disabled = !enabled
				instance.area_collision_shape.disabled = !enabled
				instance.platform_area_collision_shape.disabled = !enabled
				
		elif platform_count<platforms.size():
			var delta_count = platforms.size() - platform_count
			for _i in range(delta_count):
				remove_child(platforms.pop_back())
				
		delta_angle = (PI * 2) / platform_count
		
	if radius != last_radius:
		update() #redraw points
		last_radius = radius
		
	if color != last_color:
		for platform in platforms:
			platform.recolor_sprite.self_modulate = color
			#end_sprite_node.get_child(1).self_modulate = color
		last_color = color

func _draw():
	if(radius == 0):
		return
	var radius_vector = Vector2(radius*32, 0.0)
	
	var delta_rad = 2*PI/ceil(radius*32*2*PI/20.0) #so the points are at most 20 curve pixels appart
	var rad := 0.0
	while rad < 2.0 * PI:
		draw_circle(radius_vector.rotated(rad), 2, Color.darkgray)
		rad += delta_rad

# Called when the node enters the scene tree for the first time.
func _ready():
	var scene := load("res://scenes/actors/objects/touch_lift_platform/touch_lift_platform.tscn")
	
	delta_angle = (PI * 2) / platform_count
	for _i in range(platform_count):
		var instance = scene.instance()
		platforms.append(instance)
		add_child(instance)
		
		# Disable the collision if enabled = false
		instance.collision_shape.disabled = !enabled
		instance.area_collision_shape.disabled = !enabled
		instance.platform_area_collision_shape.disabled = !enabled

func _physics_process(delta):
	time_alive += delta * speed
	var angle := fmod(time_alive + angle_offset, (2*PI))
	for platform in platforms:
		if(mode!=1):
			platform.set_position(Vector2(radius * 32, 0).rotated(angle))
		else:
			platform.position = Vector2(radius * 32, 0).rotated(angle)
		angle += delta_angle
