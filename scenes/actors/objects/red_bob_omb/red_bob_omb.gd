extends NPCBase


const rainbow_animation_speed := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var head_color = $KinematicBody2D/AnimationHandler/Head/HeadColor

var color := Color8(255, 0, 100)
var rainbow: bool


func _set_properties():
	savable_properties = ["curve", "custom_path", "move_type", "walk_speed", "physics_enabled", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "path_reference", "dialogue_link", "color", "rainbow"]
	editable_properties = ["idle_expression", "idle_action", "speaking_expression", "speaking_action", "dialogue_link", "custom_path", "walk_speed", "move_type", "physics_enabled", "path_reference", "color", "rainbow"]


func _set_property_values():
	._set_property_values()
	
	set_property("color", color, true)


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	head_color.modulate = color
	
	if curve != path.curve:
		path.curve = curve
