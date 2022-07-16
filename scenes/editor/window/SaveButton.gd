extends Button


onready var var_name = get_node("../TextEdit")
signal clicked

func _ready():
	var connect = connect("clicked", self, "_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pressed():
	get_parent().get_parent().close()
