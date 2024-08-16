extends Node

onready var list_handler: Node = get_parent()

func generate_level_id() -> String:
	return uuid_util.v4()

func save_level(level_code: String, level_id: String, working_folder: String):
	var sorting: Node = list_handler.sorting
	var file_path: String = saved_levels_util.get_level_file_path(level_id, working_folder)
	
	saved_levels_util.save_level_code_file(level_code, file_path)
	
	sorting.add_to_list(level_id, "levels")
	sorting.save_to_json(working_folder)

func delete_level(level_id: String, working_folder: String):
	var sorting: Node = list_handler.sorting
	sorting.remove_from_list(level_id, "levels")
	sorting.save_to_json(working_folder)
	
	var file_path: String = saved_levels_util.get_level_file_path(level_id, working_folder)
	saved_levels_util.delete_file(file_path)
