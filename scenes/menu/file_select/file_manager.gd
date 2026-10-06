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
	
	var level_id = intro_level if (intro_level != "" and collected_shines < 1) else hub_level
	Singleton.SceneSwitcher.prepare_and_start_level(level_id, campaign_path, hub_level, selected_file)
