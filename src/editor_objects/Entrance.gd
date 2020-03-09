extends EditorObject

var tile_placing_offset = Vector2(16, 16)

func _ready():
	frames = load("res://scenes/actors/mario/Mario.tscn::53")
	animation = "idleRight"
	playing = true
