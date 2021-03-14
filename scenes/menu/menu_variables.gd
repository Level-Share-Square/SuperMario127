extends Node

var thread 
var main_menu_controller_scene
var resource_interactive_loader = ResourceLoader.load_interactive("res://scenes/menu/main_menu_controller/main_menu_controller.tscn")

# used to open the main menu to a specific screen, if this is a valid screen name when the main menu starts, it'll open to that screen directly
var custom_open_screen_name : String = "" 

enum screen_names {title_screen, main_menu_screen, levels_screen, shine_select_screen}
var screen_name_strings : Array = ["title_screen", "main_menu_screen", "levels_screen", "shine_select_screen"]

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	thread = Thread.new()
	thread.start(self, "load_main_menu")

func load_main_menu(userdata):
	var loaded = false
	resource_interactive_loader = ResourceLoader.load_interactive("res://scenes/menu/main_menu_controller/main_menu_controller.tscn")
	while !loaded:
		if resource_interactive_loader.poll() == ERR_FILE_EOF:
			main_menu_controller_scene = resource_interactive_loader.get_resource()
			loaded = true
		else:
			yield(get_tree().create_timer(0.15), "timeout")

func quit_to_menu(screen_to_open : String = ""): #switch this to use the enum and array
	# if we quit from the pause menu, the tree will be paused, and that means the menu will also be paused and not work
	get_tree().paused = false

	# clear out the level data of the current level, it has to be regenerated so there isn't leftover data 
	if Singleton.SavedLevels.selected_level != Singleton.SavedLevels.NO_LEVEL:
		Singleton.SavedLevels.get_current_levels()[Singleton.SavedLevels.selected_level].level_data = null
	else:
		# Go to the main menu instead of the level select
		if screen_to_open == "levels_screen":
			screen_to_open = "main_menu"
	# if the mode switcher button is visible (eg quitting from the editor), hide and disable it
	Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible = true
	Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switching_disabled = true

	custom_open_screen_name = screen_to_open
	var _change_scene = get_tree().change_scene_to(main_menu_controller_scene)

func quit_to_menu_with_transition(screen_to_open : String = ""):
	# after the transition finishes fading out, switch to the menu before starting the fade in
	var _connect = Singleton.SceneTransitions.connect("transition_finished", self, "quit_to_menu", [screen_to_open], CONNECT_ONESHOT)
	Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME, Color(1, 1, 1, 0), Color(1, 1, 1, 1))
