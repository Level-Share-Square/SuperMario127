extends Node


const QUIT_TEXT: String = "Quit"
const QUIT_OFFSET: int = -40
const QUIT_GAME_TEXT: String = "To Menu"
const QUIT_GAME_OFFSET: int = -68

onready var retry_start = $"%RetryStart"
onready var shine_map = $"%ShineMap"
onready var to_hub = $"%ToHub"

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
	var cutout = SceneTransitions.cutout_circle
	Singleton.Music.stop_temporary_music()
	SceneTransitions.reload_scene(cutout, cutout, 0.4, 0, true)

func retry_start():
	CurrentLevelData.checkpoint_data.reset()
	retry()

func to_hub():
	# music is stopped while paused, but there's a frame where it starts playing again after the transition, just kill it here to stop that
	Singleton.Music.change_song(Singleton.Music.last_song, 0)
	Singleton.Music.stop_temporary_music()
	Singleton.SceneSwitcher.quit_level(true, false)

func quit():
	# music is stopped while paused, but there's a frame where it starts playing again after the transition, just kill it here to stop that
	Singleton.Music.change_song(Singleton.Music.last_song, 0)
	Singleton.Music.stop_temporary_music()
	Singleton.SceneSwitcher.quit_level(true, true)

func set_quit_name():
	quit.text = QUIT_GAME_TEXT if CurrentLevelData.is_campaign else QUIT_TEXT
	icon.offset = Vector2(
		QUIT_OFFSET if quit.text == QUIT_TEXT else QUIT_GAME_OFFSET,
	0)
	countdown.initial_text = quit.text
	
	shine_map.visible = CurrentLevelData.is_hub_level()
	#retry_start.visible = not CurrentLevelData.is_hub_level()
	to_hub.visible = CurrentLevelData.is_campaign and not CurrentLevelData.is_hub_level()
