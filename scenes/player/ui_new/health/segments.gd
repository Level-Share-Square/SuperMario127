extends Control
tool

export var max_degrees: float
export var rotation_offset: float

func realign_segments(_node: Node = null):
	var index: float
	for child in get_children():
		child.rotation_degrees = max_degrees * (index / get_child_count())
		child.rotation_degrees += rotation_offset
		index += 1
