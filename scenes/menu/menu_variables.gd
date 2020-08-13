extends Node

const MAIN_MENU_CONTROLLER_SCENE : PackedScene = preload("res://scenes/menu/main_menu_controller/main_menu_controller.tscn")

# used to open the main menu to a specific screen, if this is a valid screen name when the main menu starts, it'll open to that screen directly
var custom_open_screen_name : String = "" 

enum screen_names {title_screen, main_menu_screen, levels_screen}
var screen_name_strings : Array = ["title_screen", "main_menu_screen", "levels_screen"]

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS

func quit_to_menu(screen_to_open : String = ""): #switch this to use the enum and array
	get_tree().paused = false
	custom_open_screen_name = screen_to_open
	var _change_scene = get_tree().change_scene_to(MAIN_MENU_CONTROLLER_SCENE)

	# add music switch and temporary music stopping
	#music.stop()
