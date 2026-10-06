extends VBoxContainer

const LEVEL_INFO_SCENE: PackedScene = preload("res://scenes/menu/pause/shine_map/level.tscn")
onready var collectible_name = $"%CollectibleName"
onready var collectible_star = $"%CollectibleStar"
onready var time_separator = $"%TimeSeparator"
onready var time_score = $"%TimeScore"

func screen_opened():
	for child in get_children():
		child.queue_free()
		
	var campaign_path: String = CurrentLevelData.working_folder
	var selected_file: int = CurrentLevelData.selected_file
	
	var sort: Dictionary = sort_file_util.load_sort_file(campaign_path)
	for level_id in sort.get("levels", []):
		var file_path: String = level_list_util.get_level_file_path(level_id, campaign_path)
		var level_code: String = level_list_util.load_level_code_file(file_path)
		var level_metadata := LevelCodeDeserializer.deserialize_level_metadata_code(LevelCodeTokenizer.splice_metadata(level_code))
		var level_save_data := LevelSaveData.new(level_id, campaign_path, level_metadata.collectible_data, selected_file)
		if level_metadata.collectible_data.get_shine_count() > 0 or level_metadata.collectible_data.get_star_coin_count() > 0:
			var level_info: Control = LEVEL_INFO_SCENE.instance()
			level_info.collectible_display = collectible_name
			level_info.collectible_star = collectible_star
			level_info.time_separator = time_separator
			level_info.time_display = time_score
			level_info.level_metadata = level_metadata
			level_info.level_save_data = level_save_data
			add_child(level_info)
