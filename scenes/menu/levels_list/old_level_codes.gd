extends VBoxContainer


signal conversion_complete

const OLD_LEVEL_CODES_FLAG_PATH: String = "user://level_list/converted"
const NEW_LEVEL_FOLDER_PATH: String = "user://level_list_100/"

onready var progress_bar = $HBoxContainer/ProgressBar
onready var thread := Thread.new()


func start(base_folder: String):
	visible = true
	thread.start(self, "convert_old_level_codes", base_folder, Thread.PRIORITY_HIGH)


func should_convert_levels():
	var file := File.new()
	return not file.file_exists(OLD_LEVEL_CODES_FLAG_PATH)


func convert_old_levels(base_folder: String):
	var new_level_dir := Directory.new()
	new_level_dir.make_dir(NEW_LEVEL_FOLDER_PATH)
	
	
	
	emit_signal("conversion_complete")
