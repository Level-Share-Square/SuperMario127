extends Button


onready var window_node = $HelpWindow
export var starting_position : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	if window_node.visible:
		window_node.close()
		window_node.rect_position = starting_position
	else:
		window_node.rect_position = starting_position
		window_node.open()
