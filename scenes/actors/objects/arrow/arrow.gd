extends GameObject

var show_behind_player = true
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

func _set_properties():
	savable_properties = ["show_behind_player", "color", "moves", "rainbow", "outline_color"]
	editable_properties = ["show_behind_player", "color", "moves", "rainbow", "outline_color"]

func _set_property_values(): 
	set_property("show_behind_player", show_behind_player, true)
	set_property("color", color, true)
	set_property("moves", moves, true)
	set_property("rainbow", rainbow, true)
	set_property("outline_color", outline_color, true)

func _ready():
	preview_position = Vector2(70, 85)
	if is_preview:
		return
	
	if show_behind_player: 
		z_index = -2
	else:
		z_index = 2

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
