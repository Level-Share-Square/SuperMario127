extends NPCBase


const rainbow_animation_speed := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var body_hair: AnimatedSprite = $"%Body/HairRecolorable"
onready var body_dress: AnimatedSprite = $"%Body/DressRecolorable"
onready var head_hair: AnimatedSprite = $"%Head/HairRecolorable"

var dress_color := Color("#ffc0c0")
var hair_color := Color.yellow
var rainbow: bool


func _register_properties():
	._register_properties()
	
	register_property(16, "dress_color", dress_color, true)
	register_property(17, "hair_color", hair_color, true)
	register_property(18, "rainbow", rainbow, true)


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		dress_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
		hair_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	body_dress.visible = (dress_color != Color("#ffc0c0"))
	body_dress.modulate = dress_color
	
	body_hair.visible = (hair_color != Color.yellow)
	body_hair.modulate = hair_color
	
	head_hair.visible = (hair_color != Color.yellow)
	head_hair.modulate = hair_color
	
	if curve != path.curve:
		path.curve = curve
