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
	register_property(8, "outline_color", outline_color)
	register_property(6, "moves", moves)
	register_property(7, "rainbow", rainbow)

func _register_property_info():
	set_property_info("color", PropertyInfo.new("The color of the object.", 1, -INF, INF, ["", ""], ["", ""]))
	set_property_info("moves", PropertyInfo.new("Move the object back and forth.", 1, -INF, INF, ["", ""], ["", ""]))
	set_property_info("rainbow", PropertyInfo.new("Steadily shift color along the rainbow.", 1, -INF, INF, ["", ""], ["", ""]))
	set_property_info("outline_color", PropertyInfo.new("The color of the object's outline.", 1, -INF, INF, ["", ""], ["", ""]))


func _ready():
	preview_position = Vector2(70, 85)
	if is_preview:
		return
		
func _editor_ready():
	connect("property_changed", self, "property_changed")
		
func property_changed(key, value):
	if key == "moves" and value == false:
		animationplayer.play("RESET")

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
