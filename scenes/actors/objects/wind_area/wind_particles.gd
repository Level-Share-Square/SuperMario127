extends Particles2D

onready var area : Area2D = get_node("../Area2D")
onready var collision : CollisionShape2D = get_node("../Area2D/CollisionShape2D")

onready var size : Vector2 = get_parent().size

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
