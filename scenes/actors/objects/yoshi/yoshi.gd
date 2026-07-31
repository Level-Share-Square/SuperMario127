extends NPCBase


const RAINBOW_ANIM_SPEED := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var head_color = $KinematicBody2D/AnimationHandler/Head/Color
onready var body_color1 = $KinematicBody2D/AnimationHandler/Body/Color1
onready var body_color2 = $KinematicBody2D/AnimationHandler/Body/Color2

var skin_color := Color.green
var shoe_color := Color.orangered
var rainbow: bool


func _register_properites():
	._register_properites()
	
	register_property(12, "skin_color", skin_color)
	register_property(13, "shoe_color", shoe_color)
	register_property(14, "rainbow", rainbow)


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		skin_color.h = float(OS.get_ticks_msec() % RAINBOW_ANIM_SPEED) / RAINBOW_ANIM_SPEED
		shoe_color.h = float(OS.get_ticks_msec() % RAINBOW_ANIM_SPEED) / RAINBOW_ANIM_SPEED
	
	head_color.modulate = skin_color
	body_color1.modulate = skin_color
	body_color2.modulate = shoe_color
	
	if curve != path.curve:
		path.curve = curve
