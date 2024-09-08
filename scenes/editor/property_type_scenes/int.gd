extends LineEdit

func _ready():
	var _connect = connect("focus_exited", self, "update")
	
func update():
	if !text.is_valid_integer():
		var old_text : String = text
		text = "0"
		if !has_letters(text):
			#parses the entered text to see if it's a valid math expression
			var expression = Expression.new()
			var error = expression.parse(old_text)
			#if it is, sets the property to it's result
			if error == OK:
				text = str(int(expression.execute()))
				get_parent().update_value()
		

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
