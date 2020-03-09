extends EditorObject

var tile_placing_offset = Vector2(16, 16)

func _ready():
	frames = load("res://assets/textures/items/coins/yellow.tres")
