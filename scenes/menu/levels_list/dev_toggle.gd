extends Control


export var dev_flag: bool
onready var list_handler = $"%ListHandler"

func screen_opened():
	list_handler.working_folder = list_handler.DEV_FOLDER if dev_flag else list_handler.BASE_FOLDER
	dev_flag = false
