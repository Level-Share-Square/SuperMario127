class_name save_meta_util


const EMPTY_DICTIONARY: Dictionary = {}


static func load_meta_file(save_folder: String) -> Dictionary:
	var file := File.new()
	var err: int = file.open_encrypted_with_pass(save_folder + "meta.127save", File.READ, level_list_util.ENCRYPTION_PASSWORD)
	if err != OK: 
		printerr("File " + save_folder + "meta.127save" + " could not be loaded. Error code: " + str(err))
		return EMPTY_DICTIONARY
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		printerr(parse.error_string)
		return EMPTY_DICTIONARY
	
	return parse.result


static func save_meta_file(save_folder: String, meta_dict: Dictionary):
	var file := File.new()
	var err: int = file.open_encrypted_with_pass(save_folder + "meta.127save", File.WRITE, level_list_util.ENCRYPTION_PASSWORD)
	if err != OK: 
		printerr("File " + save_folder + "meta.127save" + " could not be loaded. Error code: " + str(err))
		return
	
	file.store_string(JSON.print(meta_dict))
	file.close()

static func get_collectible_totals(meta_dict: Dictionary) -> Dictionary:
	var total_dict: Dictionary = {
		"total_shines": 0,
		"total_star_coins": 0,
		"collected_shines": 0,
		"collected_star_coins": 0
	}
	for level in meta_dict.get("levels", {}).values():
		total_dict["total_shines"] += level.get("total_shines", 0)
		total_dict["total_star_coins"] += level.get("total_star_coins", 0)
		total_dict["collected_shines"] += level.get("collected_shines", []).count(true)
		total_dict["collected_star_coins"] += level.get("collected_star_coins", []).count(true)
	return total_dict


static func update_meta(meta_dict: Dictionary, campaign_path: String, selected_file: int) -> Dictionary:
	meta_dict["levels"] = {}
	var sort_dict: Dictionary = sort_file_util.load_sort_file(campaign_path)
	for level_id in sort_dict.levels:
		meta_dict = update_meta_level(level_id, meta_dict, campaign_path, selected_file)
	return meta_dict

static func update_meta_level(level_id: String, meta_dict: Dictionary, campaign_path: String, selected_file: int, level_info = null) -> Dictionary:
	if not is_instance_valid(level_info):
		var file_path: String = level_list_util.get_level_file_path(level_id, campaign_path)
		var level_code: String = level_list_util.load_level_code_file(file_path)
		# weird workaround to allow instancing levelinfo without cyclic reference error
		var level_info_script = load("res://classes/LevelInfo.gd")
		level_info = level_info_script.new(level_id, campaign_path, level_code)
		
		if level_info.validity_check.is_valid:
			level_info.load_in()
		
		var save_path: String = level_list_util.get_level_save_path(level_id, campaign_path, selected_file)
		if level_list_util.file_exists(save_path):
			level_info.load_save_from_dictionary(level_list_util.load_level_save_file(save_path))
	
	meta_dict["levels"][level_id] = {}
	meta_dict["levels"][level_id]["name"] = level_info.level_name
	
	var collectible_counts: Dictionary = level_info.get_collectible_counts()
	meta_dict["levels"][level_id]["total_shines"] = collectible_counts["total_shines"]
	meta_dict["levels"][level_id]["total_star_coins"] = collectible_counts["total_star_coins"]
	meta_dict["levels"][level_id]["collected_star_coins"] = level_info.collected_star_coins.values()
	
	meta_dict["levels"][level_id]["collected_shines"] = []
	meta_dict["levels"][level_id]["shine_details"] = []
	meta_dict["levels"][level_id]["shine_times"] = []
	
	for shine_dictionary in level_info.shine_details:
		var shine_id: String = str(shine_dictionary.get("id", 0))
		meta_dict["levels"][level_id]["collected_shines"].append(level_info.collected_shines[shine_id])
		meta_dict["levels"][level_id]["shine_details"].append(shine_dictionary)
		meta_dict["levels"][level_id]["shine_times"].append(level_info.time_scores[shine_id])
	
	return meta_dict

static func update_all_with_level(level_id: String, campaign_path: String, is_erasing: bool, level_info = null) -> void:
	for selected_file in range(3):
		var save_folder: String = level_list_util.get_save_folder(campaign_path, selected_file)
		if level_list_util.file_exists(save_folder + "meta.127save"):
			var meta_dict: Dictionary = load_meta_file(save_folder)
			
			if is_erasing:
				meta_dict["levels"].erase(level_id)
			else:
				update_meta_level(level_id, meta_dict, campaign_path, selected_file, level_info)
			
			save_meta_file(save_folder, meta_dict)
