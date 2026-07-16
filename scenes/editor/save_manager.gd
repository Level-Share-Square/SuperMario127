extends Node

const UNSAVED_COLOR := Color("ff7979")

onready var action_manager = $"%ActionManager"
onready var level_settings = $"%LevelSettingsWindow"
onready var save = $"%Save"

var initial_hash: int
var unsaved_changes: bool = false


func _ready():
	initial_hash = get_hash()

func get_hash() -> int:
	return hash([action_manager.undo_stack, action_manager.redo_stack])


func _on_ActionManager_action():
	unsaved_changes = !(initial_hash == get_hash())
	if unsaved_changes:
		var tween = get_tree().create_tween()
		tween.tween_property(save, "self_modulate", UNSAVED_COLOR, 0.5)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(save, "self_modulate", Color("ffffff"), 0.5)


func _on_Quit_button_down():
	if !unsaved_changes:
		quit()
	else:
		$"%QuitConfirmWindow".toggle_window()


func _on_Save_button_down():
#	CurrentLevelData.level_info.level_name = level_settings.level_name.text
#	CurrentLevelData.level_info.level_author = level_settings.author.text
#	CurrentLevelData.level_info.level_description = level_settings.description.text
#	CurrentLevelData.level_info.thumbnail_url = level_settings.get_node("%ThumbnailURL").text #thanks godot
#	$"%Hotbar".update_level_data()
	level_settings.update_level_info()
	
	var level_id: String = CurrentLevelData.level_id
	var working_folder: String = CurrentLevelData.working_folder
	var level_code: String = LevelCodeSerializer.serialize_level_data(LevelDataContainer.new(CurrentLevelData.level_metadata, SavedEditorData.new(), [], CurrentLevelData.area_headers))
	
	var file_path = level_list_util.get_level_file_path(level_id, working_folder)
	level_list_util.save_level_code_file(level_code, file_path)
	
	for save_slot in range(4):
		var save_path = level_list_util.get_level_save_path(
			level_id, working_folder, save_slot - 1
		)
		if level_list_util.file_exists(save_path):
			level_list_util.delete_file(save_path)
			
#	CurrentLevelData.level_info.reset_save_data(false)
#	CurrentLevelData.level_info.init_collectibles()
#	save_meta_util.update_all_with_level(level_id, working_folder, false, CurrentLevelData.level_metadata)
	
	CurrentLevelData.unsaved_editor_changes = false
	level_settings.get_node("%Areas").reload_areas()
	initial_hash = get_hash()
	unsaved_changes = false
	var tween = get_tree().create_tween()
	tween.tween_property(save, "self_modulate", Color("ffffff"), 0.5)


func quit():
	var level_id: String = CurrentLevelData.level_id
	var working_folder: String = CurrentLevelData.working_folder
	var is_campaign: bool = CurrentLevelData.is_campaign
	
	var code_path: String = level_list_util.get_level_file_path(level_id, working_folder)
	var level_code: String = level_list_util.load_level_code_file(code_path)
	
	if Singleton.SceneSwitcher.menu_return_args.size() > 0:
		Singleton.SceneSwitcher.menu_return_args = [CurrentLevelData.level_info, level_id, working_folder, true, is_campaign]
	
	Singleton.Music.loop = 0
	Singleton.Music.loop_end = 0
	Singleton.Music.timer.stop()
	
	Singleton.SceneSwitcher.quit_to_menu_with_transition("levels_screen")
