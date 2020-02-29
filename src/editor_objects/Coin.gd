extends EditorObject

func _ready():
	var sprite_frames = load("res://assets/textures/items/coins/yellow.tres")
	frames = sprite_frames
	playing = true
