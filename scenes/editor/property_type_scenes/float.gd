extends LineEdit

export var limit_range : bool = false
export var min_value : float
export var max_value : float

var cursor_pos : int = 0
var _old_text := ""

func _ready():
	var _connect = connect("focus_exited", self, "update")
	_connect = connect("text_changed", self, "text_changed")

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		release_focus()

func _gui_input(event):
	if event is InputEventKey || event is InputEventMouseButton:
		cursor_pos = get_cursor_position()

func update():
	if !text.is_valid_float():
		text = "0"

func check() -> bool:
	var val := float(text)
	if val < min_value || val > max_value:
		Singleton.NotificationHandler.warning("Value of out range", "The value must be between " + str(min_value) + " and " + str(max_value))
		return false
	return true
