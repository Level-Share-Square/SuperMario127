extends VBoxContainer

signal conversion_complete

export var saver_path: NodePath
onready var saver = get_node(saver_path)

onready var progress_bar = $HBoxContainer/ProgressBar

const OLD_LEVELS_SORT_PATH: String = "user://levels/paths.json"
const OLD_LEVELS_FLAG_PATH: String = "user://levels/converted"

onready var thread := Thread.new()


func start(base_folder: String):
	visible = true
	thread.start(self, "convert_old_levels", base_folder, Thread.PRIORITY_HIGH)


func should_convert_levels():
	var file := File.new()
	return file.file_exists(OLD_LEVELS_SORT_PATH) and not file.file_exists(OLD_LEVELS_FLAG_PATH)



func convert_old_levels(base_folder: String):
	var file := File.new()
	var err: int = file.open(OLD_LEVELS_SORT_PATH, File.READ)
	if err != OK: 
		push_error("Legacy level sorting json could not be loaded. Error code: " + str(err))
		return
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		push_error(parse.error_string)
		return
	
	progress_bar.max_value = parse.result.size()
	
	var index: int = 0
	for file_path in parse.result:
		var level_dict = saved_levels_util.load_level_save_file(file_path)
		var level_code = level_dict.level_code
		var level_id = saver.generate_level_id()
		level_dict.erase("level_name")
		level_dict.erase("level_code")
		
		var save_file_path = saved_levels_util.get_level_save_path(level_id, base_folder)
		saver.save_level(level_code, level_id, base_folder)
		saved_levels_util.save_level_save_file(level_dict, save_file_path)
		
		index += 1
		progress_bar.value = index

	file.open(OLD_LEVELS_FLAG_PATH, File.WRITE)
	file.close()
	
	visible = false
	emit_signal("conversion_complete")
