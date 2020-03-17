extends AnimatedSprite

onready var entrance_node = get_node("../")

func _ready():
	visible = entrance_node.mode == 1
