extends Control


func exit_game():
	get_tree().quit()


func open_discord():
	OS.shell_open("https://discord.gg/qgfErCy")


func set_dev_toggle():
	var menu_controller: Node = get_parent().get_owner()
	var levels_list: Control = menu_controller.get_node("%LevelsList")
	var dev_toggle: Node = levels_list.get_node("%DevToggle")
	dev_toggle.dev_flag = true
