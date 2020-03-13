extends Camera2D

export var character : NodePath

onready var character_node = get_node(character)

func _process(delta):
	position = character_node.position
