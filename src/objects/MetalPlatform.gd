extends GameSolidObject

func _ready():
	frames = load("res://assets/textures/items/metal_platform/gamer.tres")
	shape.one_way_collision_margin = 0
	shape.one_way_collision = true
	shape.scale = Vector2(3.2, 0.4)
