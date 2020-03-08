extends GameObject

class_name GameSolidObject

onready var collider := StaticBody2D.new()
onready var shape := CollisionShape2D.new()

func _ready():
	shape.shape = RectangleShape2D.new()
	collider.add_child(shape)
	add_child(collider)
