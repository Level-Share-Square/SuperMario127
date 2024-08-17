extends "res://scenes/oldmenu/127Button.gd"

onready var quit_wo_saving_window = $QuitWOSavingWindow

signal open_quit_wo_saving_popup

func _ready():
	var _connect
	_connect = quit_wo_saving_window.connect("confirmed", Singleton.SceneSwitcher, "quit_to_menu_with_transition", ["levels_screen"])
	_connect = connect("open_quit_wo_saving_popup", quit_wo_saving_window, "popup_centered")

func on_pressed():
	# call the original 127 button version of this method (plays the click sound)
	.on_pressed()

	if Singleton.CurrentLevelData.unsaved_editor_changes:
		emit_signal("open_quit_wo_saving_popup")
	else:
		Singleton.SceneSwitcher.quit_to_menu_with_transition("levels_screen")
