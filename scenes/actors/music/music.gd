extends AudioStreamPlayer

export var play_bus: String
export var edit_bus: String

export var volume_multiplier = 1
var orig_volume = 1

func _ready():
	orig_volume = volume_db

func _process(delta):
	if get_tree().get_current_scene().mode == 0:
		bus = play_bus
	else:
		bus = edit_bus
	volume_db = orig_volume * volume_multiplier

func _input(event):
	if event.is_action_pressed("mute"):
		volume_multiplier = 10 if volume_multiplier == 1 else 1
