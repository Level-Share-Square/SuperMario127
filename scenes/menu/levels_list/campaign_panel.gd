extends Control


onready var title = $InfoTab/Info/Title
onready var shadow = $InfoTab/Info/Title/Shadow
onready var author = $InfoTab/Info/Author
onready var description = $InfoTab/Info/Panel/MarginContainer/Description
onready var play_campaign = $InfoTab/VBoxContainer/Buttons/PlayCampaign

onready var campaign_info = $"%CampaignInfo"
onready var loader = $"%Loader"
onready var file_manager

var working_folder: String
var campaign_id: String


func load_campaign_info(_campaign_id: String, _working_folder: String) -> void:
	campaign_id = _campaign_id
	working_folder = _working_folder 

	var campaign_path: String = level_list_util.get_folder_path(campaign_id, working_folder)
	var info_dict: Dictionary = campaign_info_util.load_info_file(campaign_path)
	title.text = campaign_id
	shadow.text = title.text
	author.text = info_dict.get("author", "Unknown")
	description.text = info_dict.get("description", "Error loading campaign info.")
	
	play_campaign.disabled = (info_dict.get("hub_level", "") == "")
	
	if not is_instance_valid(file_manager):
		var screens: Control = get_owner().get_parent()
		file_manager = screens.get_node("FileSelect").get_node("FileManager")
	file_manager.campaign_path = campaign_path


func edit_campaign() -> void:
	campaign_info.transition("LevelView")
	yield(campaign_info, "screen_change")
	loader.load_directory(level_list_util.get_folder_path(campaign_id, working_folder), true)


func delete_campaign() -> void:
	var campaign_path: String = level_list_util.get_folder_path(campaign_id, working_folder)
	level_list_util.delete_campaign_folder(campaign_path)
	
	campaign_info.transition("LevelView")
	yield(campaign_info, "screen_change")
	loader.load_directory(working_folder, false)
