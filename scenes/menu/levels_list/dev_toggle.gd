extends Control


export var dev_flag: bool
onready var list_handler = $"%ListHandler"

var first_load_flag: bool = true

func screen_opened():
	# dont wanna interfere w/ the folder when u first return from a level :P
	if Singleton.SceneSwitcher.menu_return_args.size() > 0 and first_load_flag: 
		first_load_flag = false
		return
	list_handler.working_folder = list_handler.DEV_FOLDER if dev_flag else list_handler.BASE_FOLDER
	dev_flag = false
