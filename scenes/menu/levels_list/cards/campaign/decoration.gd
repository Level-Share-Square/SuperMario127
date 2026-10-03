extends Control


onready var campaign_card: CampaignCard = get_owner()
onready var name_label = $"%Name"

func _ready():
	name_label.text = campaign_card.id
