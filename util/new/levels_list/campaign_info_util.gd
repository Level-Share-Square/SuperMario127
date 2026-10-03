class_name campaign_info_util


const DEFAULT_AUTHOR: String = "Unknown"
const DEFAULT_DESCRIPTION: String = "This is a campaign. Add some levels and give it a try!̣\n\nNote that you'll need to set a hub level in Campaign Settings first."
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


static func create_info_dict() -> Dictionary:
	var info: Dictionary = {}
	info["author"] = DEFAULT_AUTHOR
	info["description"] = DEFAULT_DESCRIPTION
	info["hub_level"] = ""
	info["intro_level"] = ""
	return info
