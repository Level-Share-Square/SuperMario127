extends Node

const MAIN_MENU_CONTROLLER_SCENE : PackedScene = preload("res://scenes/menu/main_menu_controller/main_menu_controller.tscn")

# used to open the main menu to a specific screen, if this is a valid screen name when the main menu starts, it'll open to that screen directly
var custom_open_screen_name : String = "" 

enum screen_names {title_screen, main_menu_screen, levels_screen, shine_select_screen}
var screen_name_strings : Array = ["title_screen", "main_menu_screen", "levels_screen", "shine_select_screen"]

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS

func quit_to_menu(screen_to_open : String = ""): #switch this to use the enum and array
	# if we quit from the pause menu, the tree will be paused, and that means the menu will also be paused and not work
	get_tree().paused = false

	# clear out the level data of the current level, it has to be regenerated so there isn't leftover data 
	SavedLevels.levels[SavedLevels.selected_level].level_data = null

	# if the mode switcher button is visible (eg quitting from the editor), hide and disable it
	mode_switcher.get_node("ModeSwitcherButton").invisible = true
	mode_switcher.get_node("ModeSwitcherButton").switching_disabled = true

	# add music switch and temporary music stopping
	#music.stop()

	custom_open_screen_name = screen_to_open
	var _change_scene = get_tree().change_scene_to(MAIN_MENU_CONTROLLER_SCENE)
