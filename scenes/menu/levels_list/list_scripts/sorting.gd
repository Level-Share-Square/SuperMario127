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


func sort_cards(level_grid: GridContainer, element_type: String):
	for element in sort[element_type]:
		var card = level_grid.get_node(element)
		if is_instance_valid(card):
			level_grid.move_child(card, level_grid.get_child_count())



### JSON stuff ###

func load_from_json(working_folder: String):
	var file := File.new()
	var err := file.open(working_folder + "/sort.json", File.READ)
	if err != OK: 
		assert("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		assert(parse.error_string)
		return
	
	sort = parse.result

func save_to_json(working_folder: String, is_blank: bool = false):
	var save_dict = sort
	if is_blank: 
		save_dict = {"folders": [], "levels": []}
	
	
	var file := File.new()
	var err := file.open(working_folder + "/sort.json", File.WRITE)
	if err != OK: 
		assert("File " + working_folder + "/sort.json" + " could not be loaded. Error code: " + str(err))
		return
	
	file.store_string(JSON.print(save_dict))
	file.close()
