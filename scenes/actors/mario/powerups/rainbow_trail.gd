extends AnimatedSprite

var alpha = 0.5

func _ready():
	if material != null:
		material = material.duplicate()

func _physics_process(delta):
	alpha -= 0.005
	modulate = Color(1, 1, 1, alpha)
	if alpha <= 0:
		queue_free()
