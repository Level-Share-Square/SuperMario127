extends AnimatedSprite

var alpha = 0.5

func _ready():
	for child in get_children():
		child.queue_free()
	if material != null:
		material = material.duplicate()

func _physics_process(_delta):
	alpha -= 0.005
	modulate = Color(1, 1, 1, alpha)
	if alpha <= 0:
		queue_free()
