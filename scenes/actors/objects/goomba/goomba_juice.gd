extends AnimatedSprite

const DEFAULT_COLOR := Color.red


export var lerp_speed: float = 1.0
export var color_lerp_speed: float = 1.0

export var color := DEFAULT_COLOR

var rainbow: bool = false
var rainbow_color := Color(0.95, 0, 0) # so that it doesn't ever snap to the default color

onready var recolor_sprite: AnimatedSprite = $RecolorSprite


func set_color(value: Color) -> void:
	color = value
	
	if not color.is_equal_approx(DEFAULT_COLOR):
		var true_color: Color = color
		true_color.s /= 2
		recolor_sprite.visible = true
		recolor_sprite.self_modulate = true_color
	else:
		recolor_sprite.visible = false


func _process(delta):
	if not rainbow: return
	rainbow_color.h += delta
	set_color(rainbow_color)


func _physics_process(delta):
	if not scale.is_equal_approx(Vector2.ONE):
		scale = lerp(scale, Vector2.ONE, delta * lerp_speed)

	if not modulate.is_equal_approx(Color.white):
		modulate = lerp(modulate, Color.white, delta * color_lerp_speed)
