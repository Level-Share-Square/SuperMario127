extends Control


const BACK_TEXT: String = "Back..."

onready var folder_card: FolderCard = get_owner()
onready var name_label = $"%Name"

func _ready():
	name_label.text = folder_card.id
	if folder_card.is_back:
		name_label.text = BACK_TEXT
