extends Node

export var root_path: NodePath
onready var root_scene: Control = get_node(root_path)

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
	Singleton.SceneSwitcher.quit_to_menu_with_transition("levels_screen")
