extends Control

const PLAYER_ID: int = 0

export var opacity: float = 160
export var pressed_opacity: float = 64

export var lerp_speed: float = 32.0
export var bounds: float
export var touch_grace: float


export var x_threshold: float = 0.35
export var y_threshold: float = 0.35
## fill with poolstringarrays that go as such:
## [left input, middle input (empty string), right input]
export var x_actions: Array
export var y_actions: Array


onready var bg := $BG
onready var stick := $Stick


var visual_pos: Vector2
var input_pos: Vector2
var start_finger: int
var pressed: bool


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if not pressed and rect_position.distance_to(event.position) < bounds + touch_grace:
				start_finger = event.index
				pressed = true
		else:
			if event.index == start_finger:
				pressed = false
		
		if event.index == start_finger:
			if pressed:
				move_stick(event.position)
			else:
				move_stick(rect_position)
	
	
	if event is InputEventScreenDrag:
		if pressed and event.index == start_finger:
			move_stick(event.position)


func move_stick(pos: Vector2):
	input_pos = pos - rect_position
	input_pos = input_pos.limit_length(bounds)
	
	visual_pos = input_pos
	visual_pos -= stick.rect_size / 2


func commit_action(action_name: String, is_pressed: bool):
	if action_name == "": return
	var event_action := InputEventAction.new()
	event_action.action = action_name + str(PLAYER_ID)
	event_action.pressed = is_pressed
	Input.parse_input_event(event_action)


func _ready():
	move_stick(rect_position)


var last_input_dir: Vector2
func _process(delta):
	stick.rect_position = stick.rect_position.linear_interpolate(visual_pos, delta * lerp_speed)
	modulate.a = lerp(modulate.a, (pressed_opacity / 256) if pressed else (opacity / 256), delta * lerp_speed)
	
	
	
	var normalized_input = input_pos / bounds
	var input_dir: Vector2
	
	input_dir.x -= int(normalized_input.x < -x_threshold)
	input_dir.x += int(normalized_input.x > x_threshold)
	
	input_dir.y -= int(normalized_input.y < -y_threshold)
	input_dir.y += int(normalized_input.y > y_threshold)
	
	if input_dir.x != last_input_dir.x:
		for action in x_actions:
			commit_action(action[input_dir.x + 1], true)
			commit_action(action[last_input_dir.x + 1], false)
		print("x input change: ", input_dir.x)
	
	if input_dir.y != last_input_dir.y:
		for action in y_actions:
			commit_action(action[input_dir.y + 1], true)
			commit_action(action[last_input_dir.y + 1], false)
		print("y input change: ", input_dir.y)
	
	last_input_dir = input_dir
