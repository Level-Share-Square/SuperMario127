extends GameObject

onready var effects = $ShineEffects

func _ready():
	if mode == 1:
		effects.visible = false

func _process(delta):
	effects.rotation_degrees += 1
