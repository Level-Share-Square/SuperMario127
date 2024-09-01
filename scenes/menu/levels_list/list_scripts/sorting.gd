extends Node

var sort: Dictionary = {
	"folders": [],
	"levels": []
}

func reset_values():
	sort["folders"] = []
	sort["levels"] = []


func add_to_list(element_id: String, element_type: String):
	sort[element_type].push_front(element_id)

func remove_from_list(element_id: String, element_type: String):
	sort[element_type].erase(element_id)



### JSON stuff ###

func load_from_json(working_folder: String):
	var file := File.new()
	var err: int = file.open(working_folder + "/sort.json", File.READ)
	if err != OK: 
		push_error("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		push_error(parse.error_string)
		return
	
	sort = parse.result

func save_to_json(working_folder: String, is_blank: bool = false):
	var save_dict = sort
	if is_blank: 
		save_dict = {"folders": [], "levels": []}
	
	
	var file := File.new()
	var err: int = file.open(working_folder + "/sort.json", File.WRITE)
	if err != OK: 
		push_error("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return
	
	file.store_string(JSON.print(save_dict))
	file.close()
