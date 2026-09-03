extends Node
## Transient runtime state owned by the editor: hotkey suppression and the autosave countdown.

var autosave_interval: int = 108000
var disable_hotkeys: bool = false
var time: float = 0

# this is literally just here cuz
# this is a singleton and i can
# check get_tree().paused through
# the remote inspector at runtime
# lol
# kill me
var is_tree_paused setget , get_tree_paused
func get_tree_paused(): return get_tree().paused


signal autosave

func _ready():
		set_interval(LocalSettings.load_setting("General", "autosave_interval", 900))

func reset_time() -> void:
	time = autosave_interval
	
func set_interval(interval: float):
	autosave_interval = interval
	time = interval
	
func _process(delta):
	if get_tree().current_scene is Editor:
		if time > 0:
			time -= delta
		else:
			reset_time()
			emit_signal("autosave")
			
	
