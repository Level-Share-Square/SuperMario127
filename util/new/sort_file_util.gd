class_name sort_file_util


const EMPTY_DICTIONARY: Dictionary = {}


## good if u quickly just wanna add one level arbitrarily,
## but otherwise keep your own local copy of the dictionary
## and call the save function when you're done
static func add_level_quick(working_folder: String, level_id: String):
	var sort: Dictionary = load_sort_file(working_folder)
	sort["levels"].push_front(level_id)
	save_sort_file(working_folder, sort)


static func load_sort_file(working_folder: String) -> Dictionary:
	var file := File.new()
	var err: int = file.open(working_folder + "/sort.json", File.READ)
	if err != OK: 
		push_error("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return EMPTY_DICTIONARY
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		push_error(parse.error_string)
		return EMPTY_DICTIONARY
	
	return parse.result


static func save_sort_file(working_folder: String, save_dict: Dictionary):
	var file := File.new()
	var err: int = file.open(working_folder + "/sort.json", File.WRITE)
	if err != OK: 
		push_error("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return
	
	file.store_string(JSON.print(save_dict))
	file.close()
