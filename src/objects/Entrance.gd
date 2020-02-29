extends GameObject

onready var character = get_node("../../Character")

func _ready():
	character.position = position
