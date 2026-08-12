extends VBoxContainer

onready var new_folder = $NewFolder
onready var new_campaign = $NewCampaign
onready var padding_2 = $Padding2

export var level_code_path: NodePath
onready var level_code_edit: Node = get_node(level_code_path)

export var list_handler_path: NodePath
onready var list_handler: Node = get_node(list_handler_path)

func import_level_code():
	# if the text box is empty it'll just import
	# directly from your clipboard
	var level_code: String = level_code_edit.text
	if level_code == "" and not OS.has_feature("JavaScript"):
		level_code = OS.clipboard
	
	level_code = level_code.strip_escapes().strip_edges()
	list_handler.insert_level(level_code)
	
	level_code_edit.text = ""
	level_code_edit.clear_undo_history()

func adjust_visibility(_working_folder: String) -> void:
	var is_campaign: bool = list_handler.is_campaign
	var is_base_folder: bool = list_handler.working_folder == list_handler.BASE_FOLDER
	new_folder.visible = not is_campaign
	new_campaign.visible = false
	padding_2.visible = not is_campaign
