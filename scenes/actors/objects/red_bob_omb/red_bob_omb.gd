extends NPCBase


const rainbow_animation_speed := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var head_color = $KinematicBody2D/AnimationHandler/Head/HeadColor
onready var eyes = $KinematicBody2D/AnimationHandler/Head/Eyes

var color := Color8(255, 0, 100)
var eye_color := Color8(255, 255, 255)
var rainbow: bool


#func _set_properties():
#	savable_properties = ["curve", "custom_path", "move_type", "walk_speed", "physics_enabled", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "path_reference", "tag_link", "color", "rainbow", "eye_color"]
#	editable_properties = ["idle_expression", "idle_action", "speaking_expression", "speaking_action", "tag_link", "curve", "walk_speed", "move_type", "physics_enabled", "path_reference", "color", "eye_color", "rainbow"]


func _register_properties():
	._register_properties()
	
	register_property(12, "color", color, true)
	register_property(13, "rainbow", rainbow, true)
	register_property(14, "eye_color", eye_color, true)


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	if head_color.modulate != color:
		head_color.modulate = color
	if eyes.modulate != eye_color:
		eyes.modulate = eye_color
	
	if curve != path.curve:
		path.curve = curve
