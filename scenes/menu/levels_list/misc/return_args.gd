extends Node


onready var list_handler = $"%ListHandler"


func _ready():
	var return_screen: String = Singleton.SceneSwitcher.menu_return_screen
	if return_screen != get_parent().name: return
	
	var return_args: Array = Singleton.SceneSwitcher.menu_return_args
	list_handler.working_folder = return_args[0]
