extends Control


func transition():
	var dir := Directory.new()
	if dir.file_exists("user://level_list/converted"):
		owner.transition("MainMenu")
	else:
		owner.transition("Converter")
