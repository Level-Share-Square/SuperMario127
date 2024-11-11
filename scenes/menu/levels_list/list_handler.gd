class_name LevelListHandler
extends Node

## this entire line of logic gets
## pretty complicated!! to make it more manageable,
## i split it up into several scripts in separate nodes
## this way, its easier to find what functionality happens where

signal directory_changed(new_path)

### COMMON NODES
onready var parent_screen := $"%LevelView"

onready var level_grid := $"%LevelGrid"
onready var level_panel := $"%LevelPanel"
onready var old_levels := $"%OldLevels"
onready var loader := $"%Loader"
onready var focus = $"%Focus"


### variables
const BASE_FOLDER: String = level_list_util.BASE_FOLDER
var working_folder: String = BASE_FOLDER


func _ready():
	level_list_util.create_level_folder(working_folder)
	yield(get_owner(), "screen_opened")
	
	if old_levels.should_convert_levels():
		old_levels.start(BASE_FOLDER)
		yield(old_levels, "conversion_complete")
	
	loader.thread_load_directory(working_folder)


func clear_grid():
	for child in level_grid.get_children():
		child.queue_free()


func change_focus(focus_node = null):
	if !is_instance_valid(focus_node): 
		focus_node = level_grid.get_child(0)
		print(focus_node)
	focus.default_focus = focus_node
	focus.call_deferred("focus_node")


func insert_folder():
	var folder_id: String = "New Folder"
	folder_id = level_list_util.get_valid_folder_name(folder_id, working_folder)
	
	var folder_path: String = level_list_util.get_folder_path(folder_id, working_folder)
	level_list_util.create_level_folder(folder_path)
	
	sort_file_util.add_to_sort(folder_id, working_folder, sort_file_util.FOLDERS)
	loader.add_folder_card(folder_id, working_folder, true, true)


func insert_level(level_code: String = "", folder: String = working_folder):
	if level_code == "":
		level_code = level_list_util.load_level_code_file(LevelData.DEFAULT_CODE_PATH)
	
	var level_id: String = level_list_util.generate_level_id()
	var file_path: String = level_list_util.get_level_file_path(level_id, folder)
	
	level_list_util.save_level_code_file(level_code, file_path)
	sort_file_util.add_to_sort(level_id, folder, sort_file_util.LEVELS)
	loader.add_level_card(level_id, folder, true, true, level_code)


func remove_level(level_id: String, folder: String = working_folder):
	level_list_util.wipe_level_files(level_id, folder)
	level_grid.get_node(level_id).call_deferred("queue_free")
