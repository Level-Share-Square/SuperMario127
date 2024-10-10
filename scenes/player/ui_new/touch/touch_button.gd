extends Button


export var action: String
export var player_id: int


func _ready():
	if not toggle_mode:
		connect("button_down", self, "button_action", [true])
		connect("button_up", self, "button_action", [false])
	else:
		connect("toggled", self, "button_action")


func button_action(is_pressed: bool):
	var action_name: String = action
	if player_id != -1:
		action_name += str(player_id)
	
	var event_action := InputEventAction.new()
	event_action.action = action_name
	event_action.pressed = is_pressed
	Input.parse_input_event(event_action)
