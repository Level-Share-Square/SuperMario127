extends AnimatedSprite

const LERP_SPEED: float = 0.05

export(int) var y_offset
export(Color) var opacity
var character


func _ready():
	character = get_node("../..")
	
func _process(_delta):
	if character.state == $"../../States/GroundPoundState":
		material = character.sprite.material
		frames = character.sprite.frames
		animation = character.sprite.animation
		
		show()
		offset.y = lerp(offset.y, y_offset, LERP_SPEED)
		modulate.a = lerp(modulate.a, opacity.a, LERP_SPEED)
	else:
		hide()
		offset.y = 0
		modulate.a = 1
