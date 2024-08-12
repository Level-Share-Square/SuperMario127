extends Node

onready var list_handler: Node = get_parent()

func generate_level_id() -> String:
	return uuid_util.v4()

func get_file_path(level_id: String, working_folder: String) -> String:
	return working_folder + "/" + level_id + ".127level"

func save_level(level_code: String, level_id: String, working_folder: String):
	var sorting: Node = list_handler.sorting
	var file_path: String = get_file_path(level_id, working_folder)
	
	var file := File.new()
	var err := file.open(file_path, File.WRITE)
	if err != OK:
		assert("File " + file_path + " could not be saved. Error code: " + str(err))
	
	file.store_string(level_code)
	file.close()
	
	sorting.add_to_list(level_id, "levels")
	sorting.save_to_json(working_folder)

func delete_level(level_id: String, working_folder: String):
	var sorting: Node = list_handler.sorting
	sorting.remove_from_list(level_id, "levels")
	sorting.save_to_json(working_folder)
	
	var file_path: String = get_file_path(level_id, working_folder)
	var err: int = OS.move_to_trash(ProjectSettings.globalize_path(file_path))
	if err != OK:
		assert("Failure deleting level file. Error code: " + str(err))
