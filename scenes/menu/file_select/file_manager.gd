extends Control


onready var file_cards = $"%FileCards"

var campaign_path: String
var hub_level: String
var intro_level: String

var level_played: bool = false


func screen_opened():
	var info_dict: Dictionary = campaign_info_util.load_info_file(campaign_path)
	hub_level = info_dict.get("hub_level", "")
	intro_level = info_dict.get("intro_level", "")
	
	for file_card in file_cards.get_children():
		file_card.load_file_info(campaign_path)


func play_level(selected_file: int, collected_shines: int = 0) -> void:
	if level_played: return
	level_played = true
	
	Singleton.SceneSwitcher.menu_return_screen = "MainMenu"
	Singleton.SceneSwitcher.menu_return_args = []
	CurrentLevelData.level_transition_data = {}
	CurrentLevelData.hub_return_data = {}
	
	Singleton.Music.reset_music()
	Singleton.Music.stop()
	
	var level_id = intro_level if (intro_level != "" and collected_shines < 1) else hub_level
	var file_path: String = level_list_util.get_level_file_path(level_id, campaign_path)
	var level_code: String = level_list_util.load_level_code_file(file_path)
	var level_metadata := LevelCodeDeserializer.deserialize_level_metadata_code(LevelCodeTokenizer.splice_metadata(level_code))
	Singleton.SceneSwitcher.start_level(level_metadata, level_id, campaign_path, false, false, hub_level, true, true, selected_file)
