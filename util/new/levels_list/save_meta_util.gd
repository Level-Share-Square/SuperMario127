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

static func get_collectible_totals(campaign_path: String, selected_file: int) -> Dictionary:
	var total_dict: Dictionary = {
		"total_shines": 0,
		"total_star_coins": 0,
		"collected_shines": 0,
		"collected_star_coins": 0
	}
	var sort: Dictionary = sort_file_util.load_sort_file(campaign_path)
	for level_id in sort.get("levels", []):
		var file_path: String = level_list_util.get_level_file_path(level_id, campaign_path)
		var level_code: String = level_list_util.load_level_code_file(file_path)
		var level_metadata := LevelCodeDeserializer.deserialize_level_metadata_code(LevelCodeTokenizer.splice_metadata(level_code))
		var level_save_data := LevelSaveData.new(level_id, campaign_path, level_metadata.collectible_data, selected_file)
		total_dict["total_shines"] += level_metadata.collectible_data.get_shine_count()
		total_dict["total_star_coins"] += level_metadata.collectible_data.get_star_coin_count()
		total_dict["collected_shines"] += level_save_data.get_completed_mission_count()
		total_dict["collected_star_coins"] += level_save_data.get_collected_star_coin_count()
	return total_dict
