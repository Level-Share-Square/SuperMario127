extends Node


onready var subscreens = $"%Subscreens"
onready var http_request = $"%HTTPRequest"
onready var http_level_page = $"%HTTPLevelPage"


func _ready():
	var return_screen: String = Singleton.SceneSwitcher.menu_return_screen
	if return_screen != get_parent().name: return
	
	var return_args: Array = Singleton.SceneSwitcher.menu_return_args
	for variable in return_args[1]:
		print(variable, return_args[1][variable])
		http_request[variable] = return_args[1][variable]
	
	yield(get_parent(), "screen_opened")
	yield(get_tree(), "idle_frame")
	
	http_level_page.load_level(return_args[0])
	subscreens.screen_change("")
