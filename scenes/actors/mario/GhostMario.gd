extends AnimatedSprite

onready var player = $"../Character"
onready var tween = $Tween
onready var tween2 = $Tween2
var ffc = -1
var sfc = 0

func _process(delta):
	if ffc < 3:
		ffc += 1
	if sfc < 3:
		sfc += 1
	tween.interpolate_property(self, "position", player.ghost_pos[ffc], player.ghost_pos[sfc], delta)
	tween.start()
	tween.interpolate_property(self, "animation", player.ghost_anim[ffc], player.ghost_anim[sfc], delta)
	tween.start()
#this probably works???????
