extends Node2D

func _ready():
	Engine.iterations_per_second = 60
	_update_menu_framerate()

func _update_menu_framerate():
	fps_util._update_framerate(true)
	
	get_tree().create_timer(1.0).connect("timeout", self, "_update_menu_framerate")
