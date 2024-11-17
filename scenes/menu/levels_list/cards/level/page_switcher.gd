extends Node


func _ready():
	var level_card: LevelCard = get_owner()
	var list_handler: LevelListHandler = level_card.list_handler
	
	var level_info: LevelInfo = level_card.level_info
	var level_id: String = level_card.id
	var working_folder: String = level_card.parent_folder
	
	var can_edit: bool = level_card.can_sort
	
	#warning-ignore:return_value_discarded
	level_card.call_deferred("connect", "button_pressed", list_handler.parent_screen, "transition", ["LevelInfo"])
	#warning-ignore:return_value_discarded
	level_card.call_deferred("connect", "button_pressed", list_handler.level_panel, "load_level_info", [level_info, level_id, working_folder, can_edit])
	#warning-ignore:return_value_discarded
	level_card.call_deferred("connect", "button_pressed", list_handler, "change_focus", [level_card])
