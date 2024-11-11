extends Node


## NOTE: must run before the screen manager does!!


export var screen_manager_path: NodePath
onready var screen_manager = get_node(screen_manager_path)


func _ready():
	var return_screen = Singleton.SceneSwitcher.menu_return_screen
	if return_screen != "":
		screen_manager.default_screen = return_screen
	
	return_screen = ""
