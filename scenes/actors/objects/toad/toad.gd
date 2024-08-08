extends GameObject

const rainbow_animation_speed := 1500

export (Array, String) var expression_map
export (Array, String) var action_map

onready var head := $Head
onready var spots := $Head/Spots

onready var body := $Body
onready var coat := $Body/Coat

onready var visibility_notifier := $VisibilityNotifier2D
onready var dialogue_detector := $DialogueDetector
onready var detector_collision := $DialogueDetector/CollisionShape2D

var spots_color := Color.red
var coat_color := Color.blue
var rainbow: bool

var idle_expression: int = 0
var idle_action: int = 0

var speaking_expression: int = 1
var speaking_action: int = 0

var sign_detect_radius: float = 50

func _set_properties():
	savable_properties = ["spots_color", "coat_color", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "sign_detect_radius", "rainbow"]
	editable_properties = ["spots_color", "coat_color", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "sign_detect_radius", "rainbow"]

func _set_property_values():
	set_property("spots_color", spots_color, true)
	set_property("coat_color", coat_color, true)
	
	set_property("idle_expression", idle_expression, true)
	set_property("idle_action", idle_action, true)
	
	set_property("speaking_expression", speaking_expression, true)
	set_property("speaking_action", speaking_action, true)
	
	set_property("sign_detect_radius", sign_detect_radius, true)
	set_property("rainbow", rainbow, true)

func _ready():
	stop_talking()

	if mode == 1:
		# warning-ignore: unused_variable
		connect("property_changed", self, "property_changed")
	
	# if the shape isn't cloned, each toad's detector will share the same shape
	# and thus changing one toad's radius will change every toad's radius (bad)
	detector_collision.shape = detector_collision.shape.duplicate(true)
	detector_collision.shape.radius = sign_detect_radius
	
	yield(get_tree(), "idle_frame")
	for body in dialogue_detector.get_overlapping_areas():
		var object = body.get_parent()
		if object.has_signal("message_appear"):
			object.connect("message_appear", self, "start_talking")
			object.connect("message_disappear", self, "stop_talking")
		
		if object.has_signal("message_changed"):
			object.connect("message_changed", self, "message_changed")

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
