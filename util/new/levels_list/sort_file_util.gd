class_name sort_file_util


const EMPTY_DICTIONARY: Dictionary = {}
const BASE_FOLDER: String = "user://level_list"
const LEVELS: String = "levels"
const FOLDERS: String = "folders"


static func add_to_sort(id: String, working_folder: String, sort_type: String):
	var sort: Dictionary = load_sort_file(working_folder)
	sort.get_or_add(sort_type, []).push_front(id)
	save_sort_file(working_folder, sort)


static func remove_from_sort(id: String, working_folder: String, sort_type: String):
	var sort: Dictionary = load_sort_file(working_folder)
	sort.get_or_add(sort_type, []).erase(id)
	save_sort_file(working_folder, sort)


static func load_sort_file(working_folder: String) -> Dictionary:
	var file := File.new()
	var err: int = file.open(working_folder + "/sort.json", File.READ)
	if err != OK: 
		printerr("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return EMPTY_DICTIONARY
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		printerr(parse.error_string)
		return EMPTY_DICTIONARY
	
	return parse.result


static func save_sort_file(working_folder: String, save_dict: Dictionary):
	var file := File.new()
	var err: int = file.open(working_folder + "/sort.json", File.WRITE)
	if err != OK: 
		printerr("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return
	
	file.store_string(JSON.print(save_dict))
	file.close()


static func get_start_index(sort: Dictionary, sort_type: String) -> int:
	match (sort_type):
		LEVELS:
			return get_category_size(sort, FOLDERS)
	return 0

static func get_start_index_with_back(sort: Dictionary, sort_type: String, working_folder: String) -> int:
	var start_index: int = 0 if working_folder == BASE_FOLDER else 1
	return start_index + get_start_index(sort, sort_type)

static func get_category_size(sort: Dictionary, sort_type: String) -> int:
	return sort.get(sort_type, []).size()
