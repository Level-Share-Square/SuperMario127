extends Node


onready var subscreens = $"%Subscreens"
onready var http_level_page = $"%HTTPLevelPage"


func _ready():
	var return_screen: String = Singleton.SceneSwitcher.menu_return_screen
	if return_screen != get_parent().name: return
	
	var return_args: Array = Singleton.SceneSwitcher.menu_return_args
	http_level_page.load_level(return_args[0])
	
	yield(get_parent(), "screen_opened")
	subscreens.screen_change("")