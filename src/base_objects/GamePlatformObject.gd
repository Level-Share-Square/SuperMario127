extends GameObject

class_name GamePlatformObject

onready var collider := StaticBody2D.new()
onready var shape := CollisionShape2D.new()
var collision_scale := Vector2(1, 1)
var frames_path = ""
	
func _ready():
	frames = load(frames_path)
	shape.shape = RectangleShape2D.new()
	shape.scale = collision_scale
	shape.one_way_collision_margin = 0
	shape.one_way_collision = true
	collider.add_child(shape)
	add_child(collider)
