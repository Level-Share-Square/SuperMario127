extends AnimatedSprite

onready var player = $"../Character"
onready var tween = $Tween
var ghost_pos = [Vector2(222, 2467), Vector2(224, 2467), Vector2(230, 2467), Vector2(234, 2467)]
var ghost_anim = [Vector2(222, 2467), Vector2(222, 2467), Vector2(222, 2467), Vector2(222, 2467)]
var ffc = -1
var sfc = 0

func _process(delta):
	if ffc < 3:
		ffc += 1
	if sfc < 3:
		sfc += 1
	print(ghost_pos)
	ghost_anim.append(player.sprite.animation)
	tween.interpolate_property(self, "position", ghost_pos[ffc], ghost_pos[sfc], delta)
	tween.start()
