extends GameObject

const SPEED_SCALE_MULTIPLIER = 30

onready var path = $Path2D
onready var pathfollow = $Path2D/PathFollow2D
onready var sprite = $Path2D/PathFollow2D/Saw/AnimatedSprite
onready var editor_sprite = $EditorSprite

export var circle_texture : Texture

var custom_path = Curve2D.new()
var curve = Curve2D.new()
var speed = 5
var working_speed = speed
var loops = true
var start_offset = 0

func _set_properties():
	savable_properties = ["curve", "custom_path", "speed", "start_offset", "loops"]
	editable_properties = ["custom_path", "speed", "start_offset", "loops"]
	
func _set_property_values():
	set_property("curve", curve)
	set_property("custom_path", curve)
	set_property("speed", speed)
	set_property("start_offset", start_offset)
	set_property("loops", loops)
	
func update_property(key, value):
	match(key):
		"speed":
			working_speed = value
		"loops":
			pathfollow.loop = value
		"start_offset":
			# display the editorsprite at the position the object will start at
			pathfollow.offset = value
			editor_sprite.position = pathfollow.position
		
	
func invalid_curve(check : Curve2D):
	if(!is_instance_valid(check) or check.get_point_count() == 0):
		return true
	else:
		return false
		
func _draw():
	if mode == 1:
		draw_polyline(curve.tessellate(), Color.white, 2.0)
	else:
		for offset in range(0,path.curve.get_baked_length(), 10.0):
			var pos : Vector2 = path.curve.interpolate_baked(offset)
			draw_texture_rect(circle_texture, Rect2(pos - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), false, Color.darkgray)
		
func _ready():
	if(invalid_curve(curve)):
		curve.add_point(Vector2(0, 0))
		curve.add_point(Vector2(-50, -50))
		curve.add_point(Vector2(0, -100))
		curve.add_point(Vector2(50, -50))
		curve.add_point(Vector2(0, 0))
	if(invalid_curve(path.curve)):
		path.curve = curve
	pathfollow.offset = start_offset
	pathfollow.loop = loops
	working_speed = speed
	
	if mode == 0:
		editor_sprite.visible = false
		sprite.self_modulate = Color(1, 1, 1, 1)
	else:
		editor_sprite.visible = true
		sprite.self_modulate = Color(1, 1, 1, 0.5)
		var _connect = connect("property_changed", self, "update_property")
	sprite.animation = String(palette)
	editor_sprite.animation = String(palette)
		


func _process(_delta):
	if curve != path.curve:
		path.curve = curve
		
func _physics_process(delta):
	pathfollow.offset += working_speed * delta * SPEED_SCALE_MULTIPLIER
	if !loops:
		#beautiful logic right here (makes saw move back and forward
		if pathfollow.offset >= path.curve.get_baked_length() or pathfollow.offset <= 0:
			working_speed = -working_speed
	
		
