tool

extends HelpPage

func _process(delta):
	$TileMap.position.y = -scroll_vertical
