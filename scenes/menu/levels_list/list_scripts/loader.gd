extends Node

signal loading_finished

onready var list_handler = get_parent()

onready var level_card_scene: PackedScene = preload("res://scenes/menu/levels_list/list_elements/level_card.tscn")
onready var folder_scene: PackedScene = preload("res://scenes/menu/levels_list/list_elements/folder.tscn")
onready var level_load_thread := Thread.new()

func start_level_loading(working_folder: String):
	if level_load_thread.is_active():
		level_load_thread.wait_to_finish()

	var err = level_load_thread.start(self, "load_all_levels", working_folder)
	if err != OK:
		assert("Error starting level loading thread.")

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	if level_load_thread.is_active():
		level_load_thread.wait_to_finish()


# is there no default button to focus on yet?
func load_all_levels(working_folder: String):
	var sorting: Node = list_handler.sorting

	for folder in sorting.sort.folders:
		add_folder_button(working_folder + "/" + folder, folder)
	for level in sorting.sort.levels:
		add_level_card(working_folder + "/" + level + ".127level", level, working_folder)
	
	emit_signal("loading_finished")

func add_folder_button(file_path: String, folder_name: String, move_to_front: bool = false):
	var level_grid: GridContainer = list_handler.level_grid
	var folders: Node = list_handler.folders
	
	var folder_button: Button = folder_scene.instance()
	folder_button.name = folder_name
	folder_button.get_node("Name").text = folder_name
	level_grid.call_deferred("add_child", folder_button)

	if move_to_front:
		level_grid.call_deferred("move_child", folder_button, 0)
	
	#warning-ignore:return_value_discarded
	folder_button.call_deferred("connect", "pressed", folders, "change_folder", [file_path])

func add_level_card(file_path: String, level_id: String, working_folder: String, level_code: String = "", move_to_front: bool = false):
	if level_code == "":
		level_code = saved_levels_util.load_level_code_file(file_path)
	
	var is_new_level: bool
	is_new_level = (level_code == saved_levels_util.load_level_code_file(list_handler.DEFAULT_LEVEL))
	
	var level_grid: GridContainer = list_handler.level_grid
	
	
	var level_info := LevelInfo.new(level_code)
	var level_card: Button = level_card_scene.instance()
	level_card.name = level_id
	
	# load save file
	var save_path: String = saved_levels_util.get_level_save_path(level_id, working_folder)
	if saved_levels_util.file_exists(save_path):
		level_info.load_save_from_dictionary(saved_levels_util.load_level_save_file(save_path))
	
	# needs some variables now for visual touches
	var styling = level_card.get_node("Styling")
	styling.level_info = level_info
	styling.is_complete = level_info.is_fully_completed() and not is_new_level
	
	# add node to tree
	level_card.get_node("Name").text = level_info.level_name
	
	level_grid.call_deferred("add_child", level_card)
	if move_to_front:
		level_grid.call_deferred("move_child", level_card, list_handler.folder_buttons)
	
	## some signal stuff!! the signals tell the level list
	## to transition to another screen, and then tell the
	## level info panel to start loading our level data 
	
	#warning-ignore:return_value_discarded
	level_card.call_deferred("connect", "pressed", list_handler.level_list, "transition", ["LevelInfo"])
	#warning-ignore:return_value_discarded
	level_card.call_deferred("connect", "pressed", list_handler.level_panel, "load_level_info", [level_info, level_id, working_folder])
	#warning-ignore:return_value_discarded
	# when returning from a level on controller its good to be able to start from its card
	level_card.call_deferred("connect", "pressed", list_handler, "change_focus", [level_card])
