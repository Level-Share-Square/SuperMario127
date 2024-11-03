extends Node


onready var old_data_button = $"%CleanOldData"


func open_appdata():
	OS.shell_open(OS.get_user_data_dir())


## from versions 0.8 and below
var check_folders: Array = [
	"autosave",
	"hotkeys",
	"levels",
	"template_levels"
]
var check_files: Array = [
	"080.darius",
	"081.dmitri",
	"autosave.txt",
	"bg_music.ogg",
	"LSS.login",
	"settings.json",
	"tiles.res"
]


func check_old_data(delete_data: bool):
	var has_old_data: bool = false
	
	var directory := Directory.new()
	for folder in check_folders:
		if directory.dir_exists("user://" + folder):
			if delete_data: level_list_util.delete_file("user://" + folder)
			has_old_data = true
	
	var file := File.new()
	for file_name in check_files:
		if file.file_exists("user://" + file_name):
			if delete_data: level_list_util.delete_file("user://" + file_name)
			has_old_data = true
	
	old_data_button.disabled = (not has_old_data) or delete_data 
	return has_old_data
