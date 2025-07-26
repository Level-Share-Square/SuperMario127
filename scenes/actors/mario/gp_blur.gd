extends AnimatedSprite

export(int) var y_offset
export(Color) var opacity
var character


func _ready():
	character = get_node("../..")
	character.material = material
	
func _process(delta):
	animation = character.sprite.animation
	if character.state == $"../../States/GroundPoundState":
		show()
		offset.y = lerp(offset.y, y_offset, 0.03)
		modulate.a = lerp(modulate.a, opacity.a, 0.03)
	else:
		hide()
		offset.y = 0
		modulate.a = 1
