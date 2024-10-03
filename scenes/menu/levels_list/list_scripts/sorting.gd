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


func load_from_json(working_folder: String):
	sort = sort_file_util.load_sort_file(working_folder)

func save_to_json(working_folder: String, is_blank: bool = false):
	var save_dict = sort
	if is_blank: 
		save_dict = {"folders": [], "levels": []}
	
	sort_file_util.save_sort_file(working_folder, save_dict)
