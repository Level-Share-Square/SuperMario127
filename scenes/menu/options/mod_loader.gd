extends Node


const MODS_FOLDER = "user://mods"
const ACTIVE_MOD = "active.127mod"


onready var old_data_button = $"%CleanOldData"
onready var mods_container = $"%ModsContainer"
onready var none_button = $"%NoMods"


func _ready():
	if OS.has_feature("JavaScript"):
		mods_container.hide()
		return
	
	var directory := Directory.new()
	if not directory.dir_exists(MODS_FOLDER):
		mods_container.hide()
		return
	
	directory.open(MODS_FOLDER)
	directory.list_dir_begin(true)
	
	var file: String = directory.get_next()
	while file != "":
		if file != ACTIVE_MOD:
			if file.get_extension() == "zip":
				create_mod_button(file)
		file = directory.get_next()
	directory.list_dir_end()
	
	none_button.disabled = not level_list_util.file_exists(MODS_FOLDER + "/" + ACTIVE_MOD)
	none_button.connect("pressed", self, "set_active_mod", [""])


func create_mod_button(path: String):
	var mod_button: Button = none_button.duplicate()
	mod_button.text = path.get_basename()
	mod_button.disabled = (path == Singleton2.mod_path.get_file())
	mod_button.connect("pressed", self, "set_active_mod", [path])
	mods_container.call_deferred("add_child", mod_button)


func set_active_mod(new_mod: String):
	if new_mod != "":
		var file := File.new()
		file.open(MODS_FOLDER + "/" + ACTIVE_MOD, file.WRITE)
		file.store_line(MODS_FOLDER + "/" + new_mod)
		file.close()
	else:
		var directory := Directory.new()
		directory.remove("user://mods/active.127mod")
	
	OS.execute(OS.get_executable_path(), [], false)
	get_tree().quit(0)


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
