extends Node

onready var list_handler: Node = get_parent()



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
	
	# we should be cleaning up any related files as well :)
	var thumbnail_path: String = saved_levels_util.get_level_thumbnail_path(level_id, working_folder)
	if saved_levels_util.file_exists(thumbnail_path):
		saved_levels_util.delete_file(thumbnail_path)
	
	var music_folder: String = saved_levels_util.get_level_music_folder(working_folder)
	var directory := Directory.new()
	if directory.open(music_folder) == OK:
		directory.list_dir_begin(true)
		
		var file: String = directory.get_next()
		while file != "":
			if file.begins_with(level_id):
				saved_levels_util.delete_file(music_folder + "/" + file)
			file = directory.get_next()
	
	var lss_id: String = lss_link_util.get_id_from_path(
		saved_levels_util.get_level_file_path(
			level_id,
			working_folder
		))
	if lss_id != "":
		lss_link_util.remove_level_from_link(lss_id)
