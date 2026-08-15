extends Node

export var target_screen: String = "MainMenu"

func exit():
	get_parent().transition(target_screen)
