# some initial explaination of how this works (till i make the wiki page on it):
# basically, all main menu screens get into the tree as children of the InactiveScreens node 
# then, before the player has control, the active screen is moved to the ActiveScreen node
# it's done like this so the initial paths are consistent
extends Control

# screen holders 
onready var active_screens : Control = $ActiveScreens
onready var inactive_screens : Control = $InactiveScreens 

# screens
onready var title_screen : Screen = $InactiveScreens/TitleScreen
onready var main_menu_screen : Screen = $InactiveScreens/MainMenuScreen
onready var levels_screen : Screen = $InactiveScreens/LevelsScreen
onready var shine_select_screen : Screen = $InactiveScreens/ShineSelectScreen

# this is basically a constant, except we can't store a reference to a child node in a constant, shame there's no readonly modifier
onready var default_screen = main_menu_screen

var current_screen : Screen
var previous_screen : Screen

func _ready() -> void:
	for screen in inactive_screens.get_children():
		var _connect = screen.connect("screen_change", self, "change_screen")

		# try and run an animation named default if it exists, which should reset screens to sane values
		if screen.has_node("AnimationPlayer"):
			var screen_animation_player = screen.get_node("AnimationPlayer")
			if screen_animation_player.has_animation("default"):
				screen_animation_player.play("default")

	var screen_to_load = default_screen

	var custom_open_screen_name = MenuVariables.get("custom_open_screen_name")
	var custom_open_screen = null
	if custom_open_screen_name != null:
		custom_open_screen = get(custom_open_screen_name)
	if custom_open_screen != null:
		screen_to_load = custom_open_screen

	inactive_screens.remove_child(screen_to_load)
	active_screens.add_child(screen_to_load)
	current_screen = screen_to_load

	music.change_song(music.last_song, 31) # temporary, should add a way for screens to define their own music setting later
	music.last_song = 31

# change this to use an enum or something, store enum in menu_variables
func change_screen(this_screen_name : String, new_screen_name : String):
	previous_screen = get(this_screen_name)
	current_screen = get(new_screen_name)

	previous_screen._close_screen()

	# this looks like a fair amount of copy pasted code, but honestly moving it to a function wouldn't really change much, 
	# it's not that many lines and the argument requirements would be a bit awkward

	if previous_screen.has_node("AnimationPlayer"):
		var transition_started = false

		var animation_player : AnimationPlayer = previous_screen.get_node("AnimationPlayer")
		# try and play an animation specific to this transition, if it doesn't exist try a default one
		if animation_player.has_animation("trans_out_" + current_screen.name):
			animation_player.play("trans_out_" + current_screen.name)
			transition_started = true
		elif animation_player.has_animation("trans_out_default"):
			animation_player.play("trans_out_default")
			transition_started = true

		# don't wait for an animation to finish if we didn't even start one
		if transition_started:
			# stop mouse inputs from working (add in something for controller inputs too later)
			previous_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
			yield(animation_player, "animation_finished")
			# restore mouse filter now that the animation is over
			previous_screen.mouse_filter = Control.MOUSE_FILTER_STOP

	if current_screen.has_node("AnimationPlayer"):
		var animation_player : AnimationPlayer = current_screen.get_node("AnimationPlayer")
		# try and play an animation specific to this transition, if it doesn't exist try a default one
		if animation_player.has_animation("trans_in_" + previous_screen.name):
			animation_player.play("trans_in_" + previous_screen.name)
			# kinda a hacky fix, but this solves a little visual glitch where the first frame of the next screen is the default values
			animation_player.seek(0, true)
		elif animation_player.has_animation("trans_in_default"):
			animation_player.play("trans_in_default")
			animation_player.seek(0, true)

	active_screens.remove_child(previous_screen)
	inactive_screens.add_child(previous_screen)
	
	inactive_screens.remove_child(current_screen)
	active_screens.add_child(current_screen)

	current_screen._open_screen()
