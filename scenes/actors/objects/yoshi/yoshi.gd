extends NPCBase


const rainbow_animation_speed := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var head_color = $KinematicBody2D/AnimationHandler/Head/Color
onready var body_color1 = $KinematicBody2D/AnimationHandler/Body/Color1
onready var body_color2 = $KinematicBody2D/AnimationHandler/Body/Color2

var skin_color := Color.green
var shoe_color := Color.orangered
var rainbow: bool


func _set_properties():
	savable_properties = ["curve", "custom_path", "move_type", "walk_speed", "physics_enabled", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "path_reference", "tag_link", "required_shines", "skin_color", "shoe_color", "rainbow"]
	editable_properties = ["idle_expression", "idle_action", "speaking_expression", "speaking_action", "tag_link", "custom_path", "walk_speed", "move_type", "physics_enabled", "required_shines", "path_reference", "skin_color", "shoe_color", "rainbow"]


func _set_property_values():
	._set_property_values()
	
	set_property("skin_color", skin_color, true)
	set_property("shoe_color", shoe_color, true)
	set_property("rainbow", rainbow, true)


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		skin_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
		shoe_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	head_color.modulate = skin_color
	body_color1.modulate = skin_color
	body_color2.modulate = shoe_color
	
	if curve != path.curve:
		path.curve = curve
