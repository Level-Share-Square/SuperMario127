extends Node


onready var campaign_card: CampaignCard = get_owner()

func _ready():
	var file_path: String = campaign_card.get_folder_path()
	
	#warning-ignore:return_value_discarded
	campaign_card.call_deferred(
		"connect", 
		"button_pressed", 
		campaign_card.list_handler.loader,
		"transition_to_directory", [file_path, true]
	)
