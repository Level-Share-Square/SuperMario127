# some initial explaination of how this works (till i make the wiki page on it):
# basically, all main menu screens get into the tree as children of the InactiveScreens node 
# then, before the player has control, the active screen is moved to the ActiveScreen node
# it's done like this so the initial paths are consistent
extends Control

# screen holders 
onready var active_screen : Control = $ActiveScreen 
onready var inactive_screens : Control = $InactiveScreens 

# screens
onready var title_screen : Control = $InactiveScreens/TitleScreen
onready var main_menu_screen : Control = $InactiveScreens/MainMenuScreen
onready var levels_screen : Control = $InactiveScreens/LevelsScreen

func _ready() -> void:
	for screen in inactive_screens.get_children():
		# warning-ignore: return_value_discarded
		screen.connect("screen_change", self, "change_screen")

	# for now, the title screen will be the default active screen, a way of loading a specific default should be added later
	inactive_screens.remove_child(title_screen)
	active_screen.add_child(title_screen)

func change_screen(current_screen_name : String, new_screen_name : String, transition_id : int = 0):
	var current_screen = get(current_screen_name)
	var new_screen = get(new_screen_name)

	active_screen.remove_child(current_screen)
	inactive_screens.add_child(current_screen)
	
	inactive_screens.remove_child(new_screen)
	active_screen.add_child(new_screen)
