class_name campaign_info_util


const EMPTY_DICTIONARY: Dictionary = {}


static func load_info_file(working_folder: String) -> Dictionary:
	var file := File.new()
	var err: int = file.open(working_folder + "/info.json", File.READ)
	if err != OK: 
		printerr("File " + working_folder + "/info.json" + " could not be loaded. Error code: " + str(err))
		return EMPTY_DICTIONARY
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		printerr(parse.error_string)
		return EMPTY_DICTIONARY
	
	return parse.result


static func save_info_file(working_folder: String, save_dict: Dictionary):
	var file := File.new()
	var err: int = file.open(working_folder + "/info.json", File.WRITE)
	if err != OK: 
		printerr("File " + working_folder + "/info.json" + " could not be loaded. Error code: " + str(err))
		return
	
	file.store_string(JSON.print(save_dict))
	file.close()
