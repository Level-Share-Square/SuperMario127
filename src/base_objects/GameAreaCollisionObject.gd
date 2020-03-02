extends GameObject

class_name GameAreaCollisionObject

signal on_collide
onready var area := Area2D.new()
onready var shape := CollisionShape2D.new()

func collide(body):
	emit_signal("on_collide", body)

func _ready():
	shape.shape = RectangleShape2D.new()
	area.connect("body_entered", self, "collide")
	area.add_child(shape)
	add_child(area)
	
