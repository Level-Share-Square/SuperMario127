extends Node

const PLAYER_PATH = "res://scenes/player/player.tscn"
const EDITOR_PATH = "res://scenes/editor/editor.tscn"
const SHINE_SELECT_PATH = "res://scenes/menu/shine_select/shine_select.tscn"

#### scene switching
var menu_return_screen: String
var menu_return_args: Array

func quit_to_menu(screen_to_open : String = ""):
	# if we quit from the pause menu, the tree will be paused, and that means the menu will also be paused and not work
	get_tree().paused = false 
	Singleton.CheckpointSaved.reset()
	
	# if the mode switcher button is visible (eg quitting from the editor), hide and disable it
	Singleton.ModeSwitcher.get_node("ModeSwitcherButton").invisible = true
	Singleton.ModeSwitcher.get_node("ModeSwitcherButton").switching_disabled = true
	
	var main_menu_controller_scene = ResourceLoader.load("res://scenes/menu/menu_controller/menu_controller.tscn")
	# warning-ignore: return_value_discarded
	get_tree().change_scene_to(main_menu_controller_scene)

func quit_to_menu_with_transition(screen_to_open : String = ""):
	# after the transition finishes fading out, switch to the menu before starting the fade in
	# warning-ignore: return_value_discarded
	Singleton.SceneTransitions.connect("transition_finished", self, "quit_to_menu", [screen_to_open], CONNECT_ONESHOT)
	Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME)



func setup_level(level_info: LevelInfo, level_id: String, working_folder: String):
	# load save file, if it exists
	var save_path: String = level_list_util.get_level_save_path(level_id, working_folder)
	if level_list_util.file_exists(save_path):
		level_info.load_save_from_dictionary(level_list_util.load_level_save_file(save_path))
	
	Singleton.CurrentLevelData.level_info = level_info
	Singleton.CurrentLevelData.level_data = level_info.level_data
	
	Singleton.CurrentLevelData.working_folder = working_folder
	Singleton.CurrentLevelData.level_id = level_id
	
	Singleton.CurrentLevelData.level_info.selected_shine = -1
	Singleton.CurrentLevelData.area = 0

## loads shine select if there's more than 1 shine,
## else loads directly into level
func start_level(level_info: LevelInfo, level_id: String, working_folder: String, start_in_edit_mode : bool, has_back_button: bool = false):
	setup_level(level_info, level_id, working_folder)
	
	# if it's a multi-shine level, open the shine select screen, otherwise open the level directly 
	# using collected_shines for the size check because there can only be one entry in collected shines per id, while shine_details can have multiple shines with the same id
	var goal_scene = EDITOR_PATH if start_in_edit_mode else PLAYER_PATH
	
	# Get the shine count, only count shine sprites that have show_in_menu on
	var total_shine_count := 0
	for shine_details in level_info.shine_details:
		if shine_details["show_in_menu"]:
			total_shine_count += 1
	
	# If there is more than 1, go to shine select screen
	if total_shine_count > 1:
		if start_in_edit_mode:
			# just so the menu can work properly
			level_info.selected_shine = 0
		else:
			Singleton.Music.change_song(Singleton.Music.last_song, 0)
			goal_scene = SHINE_SELECT_PATH
	
	# not a multishine level, but if there's 1 shine we should set it as selected 
	if level_info.shine_details.size() == 1:
		level_info.selected_shine = 0

	var _connect = Singleton.SceneTransitions.connect("transition_finished", get_tree(), "change_scene", [goal_scene], CONNECT_ONESHOT)
	
	Singleton.SceneTransitions.play_transition_audio()
	Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME)

## start level without setting any variables
## or doing any shine select screen checks
func force_start_level():
	var _connect = Singleton.SceneTransitions.connect("transition_finished", get_tree(), "change_scene", [PLAYER_PATH], CONNECT_ONESHOT)
	
	Singleton.SceneTransitions.do_transition_fade(Singleton.SceneTransitions.DEFAULT_TRANSITION_TIME)
