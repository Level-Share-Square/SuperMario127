tool

extends HelpPage

onready var images = $Images

func _process(delta):
	images.position.y = -scroll_vertical
