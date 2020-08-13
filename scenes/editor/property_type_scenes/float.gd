extends LineEdit

export var limit_range : bool = false
export var min_value : float
export var max_value : float

var cursor_pos : int = 0
var _old_text := ""

func _ready():
	connect("focus_exited", self, "update")
	connect("text_changed", self, "text_changed")

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		release_focus()

func _gui_input(event):
	if event is InputEventKey || event is InputEventMouseButton:
		cursor_pos = get_cursor_position()

func text_changed(new_text : String):
	if !new_text.is_valid_float() && !new_text.empty():
		text = _old_text
		set_cursor_position(cursor_pos)
	else:
		_old_text = new_text

func check() -> bool:
	var val := float(text)
	if val < min_value || val > max_value:
		NotificationHandler.warning("Value of out range", "The value must be between " + str(min_value) + " and " + str(max_value))
		return false
	return true
