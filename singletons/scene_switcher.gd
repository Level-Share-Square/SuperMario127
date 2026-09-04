extends Node

const PLAYER_PATH = "res://scenes/player/player.tscn"
const EDITOR_PATH = "res://scenes/editor/editor.tscn"
const SHINE_SELECT_PATH = "res://scenes/menu/shine_select/shine_select.tscn"

#### scene switching
var menu_return_screen: String
var menu_return_args: Array
var reload_base_folder: bool


func quit_to_menu(screen_to_open : String = ""):
	# if we quit from the pause menu, the tree will be paused, and that means the menu will also be paused and not work
	get_tree().paused = false 
	CurrentLevelData.checkpoint_data.reset()
	
	# if the mode switcher button is visible (eg quitting from the editor), hide and disable it
	Singleton.ModeSwitcher.visible = false
	Singleton.ModeSwitcher.is_switching = true
	
	var main_menu_controller_scene = ResourceLoader.load("res://scenes/menu/menu_controller/menu_controller.tscn")
	# warning-ignore: return_value_discarded
	get_tree().change_scene_to(main_menu_controller_scene)


func quit_to_menu_with_transition(screen_to_open : String = ""):
	# after the transition finishes fading out, switch to the menu before starting the fade in
	# warning-ignore: return_value_discarded
	SceneTransitions.connect("transition_finished", self, "quit_to_menu", [screen_to_open], CONNECT_ONESHOT)
	SceneTransitions.do_transition_fade(SceneTransitions.DEFAULT_TRANSITION_TIME)


func quit_level(do_transition: bool = true):
	if CurrentLevelData.is_campaign and CurrentLevelData.level_id != CurrentLevelData.hub_level:
		## ok maybe make a helper function for setting up 
		## and starting a level from its id and folder ^^;
		## this is getting to be too much boilerplate
		var level_id: String = CurrentLevelData.hub_level
		var working_folder: String = CurrentLevelData.working_folder
		var level_metadata: LevelMetadata = CurrentLevelData.level_metadata
		var hub_level: String = CurrentLevelData.hub_level
		var selected_file: int = CurrentLevelData.selected_file
		
		CurrentLevelData.level_transition_data = CurrentLevelData.hub_return_data
		CurrentLevelData.hub_return_data = {}
		
		if do_transition:
			var _connect = SceneTransitions.connect("transition_finished", self, "start_level", 
			[level_metadata, level_id, working_folder, false, true, hub_level, false, true, selected_file], CONNECT_ONESHOT)
			SceneTransitions.do_transition_fade(SceneTransitions.DEFAULT_TRANSITION_TIME)
		else:
			yield(get_tree(), "physics_frame")
			start_level(level_metadata, level_id, working_folder, false, true, hub_level, false, true, selected_file)
	else:
		CurrentLevelData.level_transition_data = {}
		CurrentLevelData.hub_return_data = {}
		CurrentLevelData.shine_kickout_data = {}
		if do_transition:
			quit_to_menu_with_transition("levels_screen")
		else:
			quit_to_menu("levels_screen")


func load_level_info(level_id: String, working_folder: String) -> LevelInfo:
	var file_path: String = level_list_util.get_level_file_path(level_id, working_folder)
	var level_code: String = level_list_util.load_level_code_file(file_path)
	var level_info := LevelInfo.new(level_id, working_folder, level_code)
	
	# load in the entire level data (we'll need it)
	if (level_info.validity_check.is_valid):
		level_info.load_in()
	
	return level_info


func setup_level(level_metadata: LevelMetadata, level_id: String, working_folder: String, hub_level: String = "", selected_file: int = -1, start_in_edit_mode: bool = false):
	# load save file, if it exists
	var save_path: String = level_list_util.get_level_save_path(level_id, working_folder, selected_file)
	if level_list_util.file_exists(save_path):
#		level_info.load_save_from_dictionary(level_list_util.load_level_save_file(save_path))
		pass
	
#	CurrentLevelData.level_info = level_info
#	CurrentLevelData.level_data = level_info.level_data
#
#	CurrentLevelData.working_folder = working_folder
#	CurrentLevelData.level_id = level_id
#	CurrentLevelData.hub_level = hub_level
#	CurrentLevelData.is_campaign = level_list_util.is_campaign(working_folder)
#	CurrentLevelData.selected_file = selected_file
#
#	CurrentLevelData.level_info.selected_shine = -1
	CurrentLevelData.load_level_headers(level_list_util.load_level_code_file(level_list_util.get_level_file_path(level_id, working_folder)))
	if not CurrentLevelData.level_transition_data.empty():
		CurrentLevelData.switch_to_area(CurrentLevelData.level_transition_data.get("target_area", 0))
	elif start_in_edit_mode:
		CurrentLevelData.switch_to_area(CurrentLevelData.editor_data.last_area)
	else:
		CurrentLevelData.switch_to_area(0)
	
	CurrentLevelData.checkpoint_data.reset()

## loads shine select if there's more than 1 shine,
## else loads directly into level
func start_level(level_metadata: LevelMetadata, level_id: String, working_folder: String, start_in_edit_mode: bool, skip_shine_select: bool = false, hub_level: String = "", do_transition: bool = true, play_warp_sound: bool = true, selected_file: int = -1):
	# if it's a multi-shine level, open the shine select screen, otherwise open the level directly 
	# using collected_shines for the size check because there can only be one entry in collected shines per id, while shine_details can have multiple shines with the same id
	var goal_scene = EDITOR_PATH if start_in_edit_mode else PLAYER_PATH
	# Get the shine count, only count shine sprites that have show_in_menu on
	var total_shine_count := 0
	for mission_uuid in level_metadata.collectible_data.used_mission_data:
		var mission = level_metadata.collectible_data.get_mission_by_uuid(mission_uuid)
		if mission["mission_show_in_menu"]:
			total_shine_count += 1
			
	CurrentLevelData.starting_nozzle = ""
	CurrentLevelData.is_new_area = true
	
	# If there is more than 1, go to shine select screen
	if total_shine_count > 1:
		if start_in_edit_mode or skip_shine_select:
			# just so the menu can work properly
			var mission: MissionData = level_metadata.collectible_data.mission_data[0]
		else:
			Singleton.Music.change_song(Singleton.Music.last_song, 0)
			goal_scene = SHINE_SELECT_PATH
	
	# not a multishine level, but if there's 1 shine we should set it as selected 
	if total_shine_count == 1 and not start_in_edit_mode:
		var mission: MissionData = level_metadata.collectible_data.mission_data[0]
		CurrentLevelData.current_mission_id = mission.mission_uuid
		CurrentLevelData.current_mission = mission
		print(mission.spawn_teleporter_tag)
		CurrentLevelData.level_transition_data = {
			"target_area": mission.spawn_area_id,
			"target_tag": mission.spawn_teleporter_tag
		}
	
	if do_transition:
		# setup level when the transition finishes so music doesnt bug out
		var _connect = SceneTransitions.connect("transition_finished", self, "level_scene_switch", [goal_scene, level_metadata, level_id, working_folder, start_in_edit_mode, skip_shine_select, hub_level, selected_file, start_in_edit_mode], CONNECT_ONESHOT)
		
		if play_warp_sound:
			SceneTransitions.play_transition_audio()
		SceneTransitions.do_transition_fade(SceneTransitions.DEFAULT_TRANSITION_TIME)
	else:
		level_scene_switch(goal_scene, level_metadata, level_id, working_folder, start_in_edit_mode, skip_shine_select, hub_level, selected_file, start_in_edit_mode)


## the final stretch...
func level_scene_switch(goal_scene: String, level_metadata: LevelMetadata, level_id: String, working_folder: String, start_in_edit_mode: bool, skip_shine_select: bool = false, hub_level: String = "", do_transition: bool = true, play_warp_sound: bool = true, selected_file: int = -1):
	var setup_result = setup_level(level_metadata, level_id, working_folder, hub_level, selected_file, start_in_edit_mode)
	if setup_result is GDScriptFunctionState:
		yield(setup_result, "completed")

	
	get_tree().change_scene(goal_scene)


## start level without setting any variables
## or doing any shine select screen checks
func force_start_level():
	if SceneTransitions.transitioning:
		yield(SceneTransitions, "transition_finished")
		
	var _connect = SceneTransitions.connect("transition_finished", get_tree(), "change_scene", [PLAYER_PATH], CONNECT_DEFERRED | CONNECT_ONESHOT)
	SceneTransitions.do_transition_fade(SceneTransitions.DEFAULT_TRANSITION_TIME)
