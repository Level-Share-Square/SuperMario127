extends GameObject

var color = Color(1, 0, 0)
var moves = false

# NEW: Animates with a rainbow effect, similar to koopas.
var rainbow := false
const rainbow_animation_speed := 500
# NEW: Change the outline color!
var outline_color = Color(1, 1, 1)

onready var sprite = $Sprite
onready var recolorable = $Recolorable
onready var animationplayer = $AnimationPlayer


func _register_properties(): 
	register_property(5, "color", color)
	register_property(6, "moves", moves)
	register_property(7, "rainbow", rainbow)
	register_property(8, "outline_color", outline_color)


func _ready():
	preview_position = Vector2(70, 85)
	if is_preview:
		return

func _process(delta):
	if rainbow:
		# Hue rotation
		color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	recolorable.modulate = color
	sprite.modulate = outline_color
	if !animationplayer.is_playing() and moves:
		animationplayer.play("move")
	if animationplayer.is_playing() and !moves:
		animationplayer.stop()
