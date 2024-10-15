extends Node


onready var folder_card: FolderCard = get_owner()

func _ready():
	var file_path: String = folder_card.get_folder_path()
	
	#warning-ignore:return_value_discarded
	folder_card.call_deferred(
		"connect", 
		"button_pressed", 
		folder_card.list_handler.loader,
		"transition_to_directory", [file_path]
	)
