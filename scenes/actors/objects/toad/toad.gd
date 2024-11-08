extends NPCBase


const rainbow_animation_speed := 1500

onready var visibility_notifier = $"%VisibilityNotifier2D"

onready var spots = $KinematicBody2D/AnimationHandler/Head/Spots
onready var coat = $KinematicBody2D/AnimationHandler/Body/Coat

var spots_color := Color.red
var coat_color := Color.blue
var rainbow: bool


func _set_properties():
	savable_properties = ["curve", "custom_path", "move_type", "walk_speed", "physics_enabled", "idle_expression", "idle_action", "speaking_expression", "speaking_action", "path_reference", "dialogue_link", "spots_color", "coat_color", "rainbow"]
	editable_properties = ["idle_expression", "idle_action", "speaking_expression", "speaking_action", "dialogue_link", "custom_path", "walk_speed", "move_type", "physics_enabled", "path_reference", "spots_color", "coat_color", "rainbow"]


func _set_property_values():
	._set_property_values()
	
	set_property("spots_color", spots_color, true)
	set_property("coat_color", coat_color, true)
	set_property("rainbow", rainbow, true)


func _process(delta):
	if not visibility_notifier.is_on_screen() and not is_preview: return
	
	if rainbow:
		spots_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
		coat_color.h = float(OS.get_ticks_msec() % rainbow_animation_speed) / rainbow_animation_speed
	
	spots.modulate = spots_color
	coat.modulate = coat_color
	
	if curve != path.curve:
		path.curve = curve
