extends Control


func transition():
	var dir := Directory.new()
	if not Singleton.PlayerSettings.game_version_mismatch or dir.file_exists("user://level_list/converted"):
		owner.transition("MainMenu")
	else:
		owner.transition("Converter")
