extends Control


onready var campaign_info = $"%CampaignInfo"
onready var loader = $"%Loader"

var working_folder: String
var campaign_id: String


func load_campaign_info(_campaign_id: String, _working_folder: String) -> void:
	campaign_id = _campaign_id
	working_folder = _working_folder


func edit_campaign() -> void:
	campaign_info.transition("LevelView")
	yield(campaign_info, "screen_change")
	loader.load_directory(level_list_util.get_folder_path(campaign_id, working_folder), true)
