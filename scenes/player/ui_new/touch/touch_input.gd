extends Node

const PLAYER_ID: int = 0
onready var timer: Timer = get_node_or_null("Timer")


export var actions: PoolStringArray

export var swipe_angle: float
export var angle_lenience: float
export var distance: float = 50

export var is_drag: bool = true
export var press_time: float = 0.15


export var check_path: NodePath
onready var check: TouchCheck = get_node_or_null(check_path)


func _ready():
	get_parent().connect("gui_input", self, "input")


var start_pos: Vector2
var cur_pos: Vector2
var start_finger: int = -1
var was_pressed: bool
func input(event):
	if is_instance_valid(check) and not check._check():
		if event is InputEventScreenTouch and is_touching():
			touch_ended(event)
#		if event is InputEventMouseButton and is_touching():
#			touch_ended(event)
		return
	
	# faster to test on mouse
#	if event is InputEventMouseButton:
#		if event.pressed:
#			touch_started(event)
#		else:
#			touch_ended(event)
#
#	if event is InputEventMouseMotion and is_touching():
#		touch_moved(event)
	
	
	if event is InputEventScreenTouch:
		if event.pressed:
			start_finger = event.index
			touch_started(event)
		elif event.index == start_finger:
			touch_ended(event)

	if event is InputEventScreenDrag and event.index == start_finger and is_touching():
		touch_moved(event)



func touch_started(event: InputEvent):
	start_pos = event.position
	cur_pos = event.position
	if is_instance_valid(timer):
		timer.start(press_time)


func touch_moved(event: InputEvent):
	cur_pos = event.position
	if not is_drag or was_pressed: return
	
	if check_distance(cur_pos):
		var angle: float = rad2deg(cur_pos.angle_to_point(start_pos))
		if abs(angle_difference(angle, swipe_angle)) < angle_lenience:
			#print("swipe registered")
			was_pressed = true
			commit_all_actions(true, true)


func touch_ended(event: InputEvent):
	if is_instance_valid(timer):
		timer.stop()
	
	if was_pressed:
		commit_all_actions(true, false)
	elif not is_drag and not check_distance(event.position):
		commit_all_actions(false)
			
	reset_touch()


func reset_touch():
	start_pos = Vector2.ZERO
	cur_pos = Vector2.ZERO
	start_finger = -1
	was_pressed = false


func press_timer_end():
	if is_instance_valid(check) and not check._check(): return
	if not is_drag and not check_distance(cur_pos):
		was_pressed = true
		commit_all_actions(true, true)



func commit_all_actions(is_held: bool, is_pressed: bool = true):
	for action_name in actions:
		commit_action(action_name, is_held, is_pressed)


func commit_action(action_name: String, is_held: bool, is_pressed: bool = true):
	var event_action := InputEventAction.new()
	event_action.action = action_name + str(PLAYER_ID)
	event_action.pressed = is_pressed
	Input.parse_input_event(event_action)
	
	if is_pressed and not is_held:
		yield(get_tree(), "physics_frame")
		event_action.pressed = false
		Input.parse_input_event(event_action)



func angle_difference(angle1, angle2) -> float:
	var diff: float = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))


func check_distance(target_pos: Vector2) -> bool:
	return start_pos.distance_to(target_pos) > distance


func is_touching() -> bool:
	return start_pos != Vector2.ZERO
