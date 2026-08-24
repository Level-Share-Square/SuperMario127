extends NPCBase


const rainbow_animation_speed := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var body = $"%Body"
onready var head = $"%Head"
onready var body_hair: AnimatedSprite = $"%Body/HairRecolorable"
onready var body_dress: AnimatedSprite = $"%Body/DressRecolorable"
onready var head_hair: AnimatedSprite = $"%Head/HairRecolorable"

export(Array, SpriteFrames) var body_palettes
export(Array, SpriteFrames) var head_palettes

var dress_color := Color("#ffc0c0")
var hair_color := Color.yellow
var rainbow: bool


func _register_properties():
	._register_properties()
	
	register_property(16, "dress_color", dress_color, true)
	register_property(17, "hair_color", hair_color, true)
	register_property(18, "rainbow", rainbow, true)


func _ready():
	._ready()
	var _connect = connect("property_changed", self, "update_property")
	update_property("palette", palette)
	update_property("hair_color", hair_color)


func update_property(key: String, value):
	if key == "palette":
		body.frames = body_palettes[value]
		head.frames = head_palettes[value]
	
	if key == "hair_color":
		body_hair.visible = (value != Color.yellow)
		body_hair.modulate = value
		
		head_hair.visible = (value != Color.yellow)
		head_hair.modulate = value


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		dress_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	body_dress.visible = (dress_color != Color("#ffc0c0"))
	body_dress.modulate = dress_color
	
	if curve != path.curve:
		path.curve = curve
