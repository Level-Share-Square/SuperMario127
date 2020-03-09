extends EditorObject

var tile_placing_offset = Vector2(0, 0)

func _ready():
	frames = load("res://assets/textures/items/radial_platform/platform.tres")
