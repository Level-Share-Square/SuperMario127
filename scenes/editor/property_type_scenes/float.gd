extends LineEdit

export var limit_range : bool = false
export var min_value : float
export var max_value : float
export var absolute: bool = false

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
		var old_text : String = text
		text = "0"
		if !has_letters(text):
			#parses the entered text to see if it's a valid math expression
			var expression = Expression.new()
			var error = expression.parse(old_text)
			#if it is, sets the property to it's result
			if error == OK:
				var value = float(expression.execute())
				if value > 0 or !absolute:
					text = str(value)
					get_parent().update_value()
	else:
		if absolute:
			if int(text) < 0:
				text = "0"

func check() -> bool:
	var val := float(text)
	if val < min_value || val > max_value:
		Singleton.NotificationHandler.warning("Value of out range", "The value must be between " + str(min_value) + " and " + str(max_value))
		return false
	return true

func has_letters(string : String):
	var regex = RegEx.new()
	regex.compile("[a-zA-Z]+")
	if regex.search(str(string)):
		return true
	else:
		return false
