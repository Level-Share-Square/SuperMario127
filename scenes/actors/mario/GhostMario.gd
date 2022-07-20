extends AnimatedSprite

onready var player = get_parent().get_node("Character")
onready var tween = $Tween
var ghost_pos = []
var ghost_anim = []
var ffc = -1
var sfc = 0

func _process(delta):
	pass
