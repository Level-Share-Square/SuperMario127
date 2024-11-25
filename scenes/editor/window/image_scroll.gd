extends HelpPage

onready var images = get_node("Images")

func _process(delta):
	images.position.y = -scroll_vertical
