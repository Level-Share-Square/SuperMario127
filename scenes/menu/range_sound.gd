extends Range
class_name RangeSound

onready var hover_sound: AudioStreamPlayer = get_parent().get_node("%HoverSound") 
onready var click_sound: AudioStreamPlayer = get_parent().get_node("%ClickSound") 

export var hover_override: String
export var click_override: String


func _ready() -> void:
	if hover_override != "":
		hover_sound = get_parent().get_node("%" + hover_override)
	if click_override != "":
		click_sound = get_parent().get_node("%" + click_override)
	
	#warning-ignore:return_value_discarded
	connect("focus_entered", self, "on_focus_entered")
	#warning-ignore:return_value_discarded
	connect("value_changed", self, "play_sound")


func on_focus_entered() -> void:
	hover_sound.play()

func play_sound(val) -> void:
	click_sound.pitch_scale = map(val, min_value, max_value, 0.5, 2.0)
	click_sound.play()
	yield(click_sound, "finished")
	click_sound.pitch_scale = 1.0


static func map(value: float, value_min: float, value_max: float, new_min: float, new_max: float) -> float:
	var clamped_value = clamp(value, value_min, value_max)
	return (clamped_value - value_min) * (new_max - new_min) / (value_max - value_min) + new_min
