extends NPCBase


const rainbow_animation_speed := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var body = $KinematicBody2D/AnimationHandler/Body
onready var head = $KinematicBody2D/AnimationHandler/Head
onready var body_base = $KinematicBody2D/AnimationHandler/Body/Base
onready var head_base = $KinematicBody2D/AnimationHandler/Head/Base
onready var spots = $KinematicBody2D/AnimationHandler/Head/Spots
onready var coat = $KinematicBody2D/AnimationHandler/Body/Coat

export(Array, SpriteFrames) var body_palettes
export(Array, SpriteFrames) var head_palettes

var spots_color := Color.red
var coat_color := Color.blue
var base_color := Color.white
var rainbow: bool


#func _set_properties():
#	savable_properties = ["curve", "custom_path", "move_type", "walk_speed", "physics_enabled", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "path_reference", "tag_link", "required_shines", "spots_color", "coat_color", "rainbow"]
#	editable_properties = ["idle_expression", "idle_action", "speaking_expression", "speaking_action", "tag_link", "curve", "walk_speed", "move_type", "physics_enabled", "required_shines", "path_reference", "spots_color", "coat_color", "rainbow"]


func _register_properties():
	._register_properties()
	register_property(16, "spots_color", spots_color, true)
	register_property(17, "coat_color", coat_color, true)
	register_property(19, "base_color", base_color, true)
	register_property(18, "rainbow", rainbow, true)


func _ready():
	._ready()
	var _connect = connect("property_changed", self, "update_property")
	update_property("palette", palette)
	update_property("base_color", base_color)


func update_property(key: String, value):
	if key == "palette":
		body.frames = body_palettes[value]
		head.frames = head_palettes[value]
	
	if key == "base_color":
		head_base.visible = (value != Color.white)
		head_base.modulate = value
		body_base.visible = (value != Color.white)
		body_base.modulate = value


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		spots_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
		coat_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	spots.modulate = spots_color
	coat.modulate = coat_color
	
	if curve != path.curve:
		path.curve = curve
