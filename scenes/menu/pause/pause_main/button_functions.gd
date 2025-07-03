extends Node


const QUIT_TEXT: String = "Quit"
const QUIT_OFFSET: int = -40
const HUB_TEXT: String = "To Hub"
const HUB_OFFSET: int = -56

onready var quit = $"%Quit"
onready var icon = quit.get_node("Icon")
onready var countdown = quit.get_node("Countdown")

export var root_path: NodePath
onready var root_scene: Control = get_node(root_path)

onready var player_scene: Node = get_tree().get_current_scene()
onready var pause_controller = root_scene.get_parent().get_parent()

func resume():
	pause_controller.pause()

func retry():
	var cutout = Singleton.SceneTransitions.cutout_circle
	Singleton.Music.stop_temporary_music()
	Singleton.SceneTransitions.reload_scene(cutout, cutout, 0.4, 0, true)

func retry_start():
	Singleton.CheckpointSaved.reset()
	retry()

func quit():
	# music is stopped while paused, but there's a frame where it starts playing again after the transition, just kill it here to stop that
	Singleton.Music.change_song(Singleton.Music.last_song, 0)
	Singleton.Music.stop_temporary_music()
	Singleton.SceneSwitcher.quit_level()

func set_quit_name():
	quit.text = QUIT_TEXT if Singleton.CurrentLevelData.is_hub_level() else HUB_TEXT
	icon.offset = Vector2(
		QUIT_OFFSET if Singleton.CurrentLevelData.is_hub_level() else HUB_OFFSET,
	0)
	
	countdown.initial_text = quit.text
