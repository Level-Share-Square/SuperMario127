tool

extends ScrollContainer

func _process(delta):
	$TileMap.position.y = -scroll_vertical
