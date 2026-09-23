extends AnimatedSprite

const DEFAULT_COLOR := Color.blue
const DEFAULT_BOOTS_COLOR := Color.red

onready var recolorable_0 = $Recolorable0
onready var recolorable_1 = $Recolorable1
onready var recolorable_boots = $RecolorableBoots

export var color: Color = DEFAULT_COLOR
export var boots_color: Color = DEFAULT_BOOTS_COLOR
export var lerp_speed: float = 1.0
export var color_lerp_speed: float = 1.0
export var unsquished_frames: SpriteFrames
export var squished_frames: SpriteFrames

var rainbow: bool = false
var rainbow_color := Color(0.95, 0, 0) # so that it doesn't ever snap to the default color

func _process(delta):
	if not rainbow: return
	rainbow_color.h += delta
	set_color(rainbow_color)
	set_boots_color(Color.white)


func set_color(value: Color) -> void:
	color = value
	
	if not color.is_equal_approx(DEFAULT_COLOR):
		var highlight_color: Color = color
		highlight_color.s /= 2
		recolorable_0.visible = true
		recolorable_1.visible = true
		recolorable_0.self_modulate = color
		recolorable_1.self_modulate = highlight_color
	else:
		recolorable_0.visible = false
		recolorable_1.visible = false


func set_boots_color(value: Color) -> void:
	boots_color = value
	
	if not boots_color.is_equal_approx(DEFAULT_BOOTS_COLOR):
		recolorable_boots.visible = true
		recolorable_boots.self_modulate = boots_color
	else:
		recolorable_boots.visible = false


func set_squished(value) -> void:
	frames = squished_frames if value else unsquished_frames


func set_rainbow(value) -> void:
	rainbow = value
	set_color(color)
	set_boots_color(boots_color)

func _physics_process(delta):
	if not scale.is_equal_approx(Vector2.ONE):
		scale = lerp(scale, Vector2.ONE, delta * lerp_speed)

	if not modulate.is_equal_approx(Color.white):
		modulate = lerp(modulate, Color.white, delta * color_lerp_speed)
