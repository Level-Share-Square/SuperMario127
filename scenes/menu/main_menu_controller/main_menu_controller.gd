# some initial explaination of how this works (till i make the wiki page on it):
# basically, all main menu screens get into the tree as children of the InactiveScreens node 
# then, before the player has control, the active screen is moved to the ActiveScreen node
# it's done like this so the initial paths are consistent
extends Control

# screen holders 
onready var active_screens : Control = $ActiveScreens
onready var inactive_screens : Control = $InactiveScreens 

# screens
onready var splash_screen : Screen = $InactiveScreens/SplashScreen
onready var title_screen : Screen = $InactiveScreens/TitleScreen
onready var main_menu_screen : Screen = $InactiveScreens/MainMenuScreen
onready var levels_screen : Screen = $InactiveScreens/LevelsScreen
onready var options_screen : Screen = $InactiveScreens/MultiplayerOptions
onready var controls_screen : Screen = $InactiveScreens/ControlsOptions
onready var shine_select_screen : Screen = $InactiveScreens/ShineSelectScreen

# other
onready var backgrounds : Node2D = $Background/Backgrounds

# this is basically a constant, except we can't store a reference to a child node in a constant, shame there's no readonly modifier
onready var default_screen = splash_screen

var current_screen : Screen
var previous_screen : Screen

var possible_backgrounds = [
	4
]
var possible_parallax = [
	8
]

func _ready() -> void:
	randomize()
	
	var picked_background = possible_backgrounds[randi() % possible_backgrounds.size()]
	var picked_parallax = possible_parallax[randi() % possible_parallax.size()]
	
	backgrounds.update_background(picked_background, picked_parallax, Rect2(0, 0, 24, 14), 128, 0)
	backgrounds.do_auto_scroll = true
	
	for screen in inactive_screens.get_children():
		var _connect = screen.connect("screen_change", self, "start_changing_screens")

		# try and run an animation named default if it exists, which should reset screens to sane values
		if screen.has_node("AnimationPlayer"):
			var screen_animation_player = screen.get_node("AnimationPlayer")
			if screen_animation_player.has_animation("default"):
				screen_animation_player.play("default")

	var screen_to_load = default_screen

	var custom_open_screen_name = Singleton.MenuVariables.get("custom_open_screen_name")
	var custom_open_screen = null
	if custom_open_screen_name != null:
		custom_open_screen = get(custom_open_screen_name)
	if custom_open_screen != null:
		screen_to_load = custom_open_screen

	# properly load a default screen
	inactive_screens.remove_child(screen_to_load)
	active_screens.add_child(screen_to_load)
	screen_to_load._open_screen()
	screen_to_load.can_interact = true

	Singleton.Music.stop_temporary_music()
	Singleton.Music.change_song(Singleton.Music.last_song, 31) # temporary, should add a way for screens to define their own music setting later
	Singleton.Music.last_song = 31
	
	Singleton.CheckpointSaved.reset()
	Singleton.CurrentLevelData.area = 0
	Singleton.CurrentLevelData.level_data.vars.init()
	Singleton.MiscShared.is_play_reload = false

# change this to use an enum or something, store enum in menu_variables
func start_changing_screens(this_screen_name : String, new_screen_name : String) -> void:
	release_focus()

	previous_screen = get(this_screen_name)
	current_screen = get(new_screen_name)

	previous_screen.can_interact = false

	previous_screen._close_screen()
	current_screen._pre_open_screen()

	# make the screen we're moving to visible during the transition 
	# once simultanious transition animations are implemented an animatiion could be used to hide it if needed
	inactive_screens.remove_child(current_screen)
	active_screens.add_child(current_screen)
	# make sure to place it behind the screen we're transitioning out from
	active_screens.move_child(current_screen, 0)

	var previous_screen_anim_length = previous_screen.play_screen_transition(true, previous_screen.name, current_screen.name)
	var current_screen_anim_length = current_screen.play_screen_transition(true, previous_screen.name, current_screen.name)

	if previous_screen_anim_length == 0 and current_screen_anim_length == 0:
		finish_changing_screens()
	elif previous_screen_anim_length > current_screen_anim_length:
		var _connect = previous_screen.get_node("AnimationPlayer").connect("animation_finished", self, \
				"finish_changing_screens", [], CONNECT_ONESHOT)
	else:
		var _connect = current_screen.get_node("AnimationPlayer").connect("animation_finished", self, \
				"finish_changing_screens", [], CONNECT_ONESHOT)

# called when the fade out animation finishes
# argument exists just to satify the requirements of the animation_finished signal that is used to call this
func finish_changing_screens(_anim_name : String = "") -> void:
	var _anim_length
	_anim_length = previous_screen.play_screen_transition(false, previous_screen.name, current_screen.name)
	_anim_length = current_screen.play_screen_transition(false, previous_screen.name, current_screen.name)

	# make the screen we're leaving inactive
	active_screens.remove_child(previous_screen)
	inactive_screens.add_child(previous_screen)
	
	current_screen._open_screen()
	current_screen.can_interact = true
