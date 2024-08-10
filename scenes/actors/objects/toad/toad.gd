extends GameObject

const rainbow_animation_speed := 1500

export (Array, String) var expression_map
export (Array, String) var action_map

onready var head := $Head
onready var spots := $Head/Spots

onready var body := $Body
onready var coat := $Body/Coat

onready var path = $Path2D
onready var pathfollow = $Path2D/PathFollow2D

onready var visibility_notifier := $VisibilityNotifier2D

var dialogue := PoolStringArray(["0100This is a dialogue object.", "0100Try putting changing the expressions and see what happens!"])
var character_name: String = "Toad"

var curve = Curve2D.new()
var custom_path = Curve2D.new()
var walk_speed : float = 2
var physics_enabled = true

var spots_color := Color.red
var coat_color := Color.blue
var rainbow: bool

var idle_expression: int = 0
var idle_action: int = 0

var speaking_expression: int = 1
var speaking_action: int = 0

var speaking_radius: float = 90

func _set_properties():
	savable_properties = ["dialogue", "character_name", "curve", "custom_path", "walk_speed", "physics_enabled", "spots_color", "coat_color", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "speaking_radius", "rainbow"]
	editable_properties = ["dialogue", "character_name", "custom_path", "walk_speed", "physics_enabled", "spots_color", "coat_color", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "speaking_radius", "rainbow"]

func _set_property_values():		
	set_property("dialogue", dialogue, true)
	set_property("character_name", character_name, true)
	
	set_property("curve", curve, true)
	set_property("custom_path", curve, true)
	set_property("walk_speed", walk_speed, true)
	set_property("physics_enabled", physics_enabled, true)
	
	set_property("spots_color", spots_color, true)
	set_property("coat_color", coat_color, true)
	
	set_property("idle_expression", idle_expression, true)
	set_property("idle_action", idle_action, true)
	
	set_property("speaking_expression", speaking_expression, true)
	set_property("speaking_action", speaking_action, true)
	
	set_property("speaking_radius", speaking_radius, true)
	set_property("rainbow", rainbow, true)

func _ready():
	stop_talking()
	
	path.global_position = global_position
	if(invalid_curve(curve)):
		curve.add_point(Vector2(0, 0))
		curve.add_point(Vector2(-50, -50))
		curve.add_point(Vector2(0, -100))
		curve.add_point(Vector2(50, -50))
		curve.add_point(Vector2(0, 0))
	if(invalid_curve(path.curve)):
		path.curve = curve
	
	if mode == 1:
		# warning-ignore: unused_variable
		connect("property_changed", self, "property_changed")

	yield(get_tree(), "idle_frame")
	
	
func invalid_curve(check : Curve2D):
	if(!is_instance_valid(check) or check.get_point_count() == 0):
		return true
	else:
		return false

func property_changed(key: String, value):
	match(key):
		"idle_expression":
			idle_expression = clamp(value, 0, expression_map.size() -1)
		"speaking_expression": 
			speaking_expression = clamp(value, 0, expression_map.size() - 1)

		"idle_action": 
			idle_action = clamp(value, 0, action_map.size() - 1)
		"speaking_action": 
			speaking_action = clamp(value, 0, action_map.size() - 1)
	
	stop_talking()


func start_talking():
	head.play(expression_map[speaking_expression])
	body.play(action_map[speaking_action])

func stop_talking():
	head.play(expression_map[idle_expression])
	body.play(action_map[idle_action])

func message_changed(expression, action):
	head.play(expression_map[expression])
	body.play(action_map[action])


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		spots_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
		coat_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	spots.modulate = spots_color
	coat.modulate = coat_color
	
	if curve != path.curve:
		path.curve = curve
