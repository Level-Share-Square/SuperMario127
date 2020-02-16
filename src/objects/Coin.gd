extends Sprite

signal on_collect
onready var body := KinematicBody2D.new()
onready var shape := CollisionShape2D.new()

func collect():
	emit_signal("on_collect")
	queue_free()

func _ready():
	texture = load("res://assets/textures/items/coins/yellow.png")
	shape.shape = RectangleShape2D.new()
	body.add_child(shape)
	add_child(body)

func _physics_process(delta):
	if body.test_move(transform, Vector2(0, 0)):
		collect()
