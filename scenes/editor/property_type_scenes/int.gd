extends LineEdit

export var absolute: bool = false

func _ready():
	var _connect = connect("focus_exited", self, "update")
	
func update():
	if !text.is_valid_integer():
		var old_text : String = text
		text = "0"
		if !has_letters(old_text):
			#parses the entered text to see if it's a valid math expression
			var expression = Expression.new()
			var error = expression.parse(old_text)
			#if it is, sets the property to it's result
			if error == OK:
				var value = int(expression.execute())
				if value > 0 or !absolute:
					text = str(value)
					get_parent().update_value()
	else:
		if absolute:
			if int(text) < 0:
				text = "0"
		

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		release_focus()

func has_letters(string : String):
	var regex = RegEx.new()
	regex.compile("[a-zA-Z]+")
	if regex.search(str(string)):
		return true
	else:
		return false
