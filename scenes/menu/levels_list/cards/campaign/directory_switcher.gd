extends Node


onready var campaign_card: CampaignCard = get_owner()

func _ready():
	var file_path: String = campaign_card.get_folder_path()
	var list_handler: LevelListHandler = campaign_card.list_handler
	
	#warning-ignore:return_value_discarded
	campaign_card.call_deferred("connect", "button_pressed", list_handler.parent_screen, "transition", ["CampaignInfo"])
	#warning-ignore:return_value_discarded
	campaign_card.call_deferred("connect", "button_pressed", list_handler, "change_focus", [campaign_card])
	#warning-ignore:return_value_discarded
	campaign_card.call_deferred("connect", "button_pressed", list_handler.campaign_panel, "load_campaign_info", 
		[campaign_card.id, campaign_card.parent_folder])
