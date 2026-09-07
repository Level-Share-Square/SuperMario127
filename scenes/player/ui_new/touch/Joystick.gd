extends MarginContainer


const PLAYER_ID: int = 0

onready var bg := $BG
onready var stick_container := $StickContainer
onready var bounds: float = (rect_size.x / 2) - margin_left

export var opacity: float = 160
export var pressed_opacity: float = 128
export var lerp_speed: float = 32.0

export var x_threshold: float = 0.35
export var y_threshold: float = 0.35
## fill with poolstringarrays that go as such:
## [left input, middle input (empty string), right input]
export var x_actions: Array
export var y_actions: Array

var visual_pos: Vector2
var input_pos: Vector2
var start_finger: int
var pressed: bool


func _gui_input(event):
	if event is InputEventScreenTouch:
		var true_bounds: float = bounds * ((rect_scale.x + rect_scale.y)/2)
		var center_position: Vector2 = rect_size / 2
		
		if event.pressed:
			prints((rect_size.x / 2) - margin_left)
			if not pressed:
				start_finger = event.index
				pressed = true
		else:
			if event.index == start_finger:
				pressed = false
		
		if event.index == start_finger:
			if pressed:
				move_stick(event.position)
			else:
				move_stick(center_position)
	
	if event is InputEventScreenDrag:
		if pressed and event.index == start_finger:
			move_stick(event.position)


func move_stick(pos: Vector2):
	input_pos = (pos - rect_size/2).limit_length(bounds)
	visual_pos = input_pos + rect_size/2


func commit_action(action_name: String, is_pressed: bool):
	if action_name == "": return
	var event_action := InputEventAction.new()
	event_action.action = action_name + str(PLAYER_ID)
	event_action.pressed = is_pressed
	Input.parse_input_event(event_action)


func _ready():
	move_stick(rect_size / 2)


var last_input_dir: Vector2
func _process(delta):
	stick_container.rect_position = stick_container.rect_position.linear_interpolate(visual_pos, delta * lerp_speed)
	modulate.a = lerp(modulate.a, (pressed_opacity / 256) if pressed else 1.0, delta * lerp_speed)
	
	var true_bounds: float = bounds * ((rect_scale.x + rect_scale.y)/2)
	var normalized_input = input_pos / true_bounds
	var input_dir: Vector2
	
	input_dir.x -= int(normalized_input.x < -x_threshold)
	input_dir.x += int(normalized_input.x > x_threshold)
	
	input_dir.y -= int(normalized_input.y < -y_threshold)
	input_dir.y += int(normalized_input.y > y_threshold)
	
	if input_dir.x != last_input_dir.x:
		for action in x_actions:
			commit_action(action[input_dir.x + 1], true)
			commit_action(action[last_input_dir.x + 1], false)
		#print("x input change: ", input_dir.x)
	
	if input_dir.y != last_input_dir.y:
		for action in y_actions:
			commit_action(action[input_dir.y + 1], true)
			commit_action(action[last_input_dir.y + 1], false)
		#print("y input change: ", input_dir.y)
	
	last_input_dir = input_dir
