extends Button

var string
signal clicked

func _ready():
	var connect = connect("clicked", self, "_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pressed():
	string.text.text = get_parent().get_node("TextEdit").text
	string.update_value()
	get_parent().get_parent().close()
