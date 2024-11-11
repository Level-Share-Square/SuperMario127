extends CanvasLayer

signal shine_collected

onready var cooldown = $Cooldown
onready var blur = $Blur/Shader
onready var blur_animation = $Blur/Shader/Animation

onready var screen_manager = $Screens

var is_open

func _ready():
	Singleton.CurrentLevelData.can_pause = true

func set_tree_paused(value: bool):
	Singleton.CurrentLevelData.set_process(!value)
	get_tree().paused = value

func can_pause() -> bool:
	return Singleton.CurrentLevelData.can_pause and !Singleton.SceneTransitions.transitioning

func pause():
	if !cooldown.is_stopped(): return
	cooldown.start()
	
	if is_open:
		is_open = false
		screen_manager.current_screen.transition("")
		blur_animation.play("transition")
		
		cooldown.connect("timeout", self, "set_tree_paused", [false], CONNECT_ONESHOT)
		
	elif can_pause():
		is_open = true
		screen_manager.screen_change("MainMenu")
		blur_animation.play_backwards("transition")
		set_tree_paused(true)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause()

## so we can simply ask it "are you stopped?"
## instead of doing more convoluted stuff
func cooldown_timeout():
	cooldown.stop()
