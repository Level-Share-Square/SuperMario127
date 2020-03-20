extends TextureButton

export var window : NodePath
export var starting_position : Vector2
onready var window_node = get_node(window)

func _pressed():
	window_node.visible = !window_node.visible
	window_node.rect_position = starting_position
