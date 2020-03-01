extends EditorObject

func _ready():
	frames = load("res://scenes/actors/mario/Mario.tscn::53")
	animation = "idleRight"
	playing = true
