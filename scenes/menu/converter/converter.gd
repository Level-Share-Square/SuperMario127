extends Node

onready var status_label = $"%StatusLabel"
onready var progress_bar = $"%ProgressBar"
onready var progress_label = $"%ProgressLabel"
onready var old_levels = $OldLevels

const TIMEOUT_FACTOR: float = 10000.0

export var status_converting: String
export var status_done_default: String
export var status_done_js: String
var status_done: String

var conversion_thread: Thread
var files_to_convert: Array
var saves_to_convert: Array
var thumbnails_to_convert: Array

var thread_timer: float = 0.0
var thread_timeout: float = -1.0
var thread_timer_on: bool = false

var failed_files: Array
var failed_threads: Array
var current_file: String = ""

var started_converting: bool

signal conversion_done

func start():
	if started_converting: return
	started_converting = true
	
	status_done = status_done_js if OS.has_feature("JavaScript") else status_done_default
	var dir := Directory.new()
	if Singleton.PlayerSettings.game_version_mismatch and not dir.file_exists("user://level_list/converted"):
		if dir.dir_exists("user://levels"):
			status_label.text = status_converting
			old_levels.start(level_list_util.BASE_FOLDER)
			yield(old_levels, "conversion_complete")
		conversion()
	else:
		progress_bar.hide()
		progress_label.hide()
		status_label.text = status_done
		if not OS.has_feature("JavaScript"):
			call_deferred("emit_signal", "conversion_done")

func conversion():
	var dir := Directory.new()
	
	if not dir.file_exists("user://level_list/converted") and dir.dir_exists("user://level_list_old"): remove_recursive("user://level_list")
	dir.rename("user://level_list", "user://level_list_old")
	if not dir.dir_exists("user://level_list"): dir.make_dir("user://level_list")
	
	var data: Array = get_files_for_conversion()
	files_to_convert = data[0]
	saves_to_convert = data[1]
	thumbnails_to_convert = data[2]
	
	status_label.text = status_converting
	progress_bar.max_value = files_to_convert.size()
	
	if not (files_to_convert.empty() and saves_to_convert.empty()):
		conversion_thread = Thread.new()
		conversion_thread.start(self, "convert_thread", files_to_convert, Thread.PRIORITY_HIGH)
		thread_timer_on = true
	else:
		on_conversion_finished()

func _process(delta):
	if current_file and thread_timer_on:
		thread_timer += delta
		prints("CURRENT THREAD TIMER:", thread_timer, "\nTIMEOUT:", thread_timeout)
			
		if thread_timer > thread_timeout:
			printerr("Failed to convert: ", current_file)
			failed_files.append(current_file)
			failed_threads.append(conversion_thread)
			
			files_to_convert.erase(current_file)
			current_file = ""
			
			if not files_to_convert.empty():
				conversion_thread = Thread.new()
				conversion_thread.start(self, "convert_thread", files_to_convert, Thread.PRIORITY_HIGH)
			else:
				on_conversion_finished()

func convert_thread(files: Array):
	var dir := Directory.new()
	
	for old_file_path in files:
		call_deferred("start_file_timer", old_file_path)
		
		var new_file_path: String = old_file_path.replace("level_list_old", "level_list")
		var working_folder: String = new_file_path.get_base_dir()
		
		if not dir.dir_exists(working_folder): dir.make_dir_recursive(working_folder)
		
		var old_level_code: String = level_list_util.load_level_code_file(old_file_path)
		var new_level_code: String = CurrentLevelData.convert_old_code_to_new(old_level_code)
		
		level_list_util.save_level_code_file(new_level_code, new_file_path)
		
		call_deferred("finish_file", old_file_path)
		
	convert_inner(saves_to_convert)
	convert_inner(thumbnails_to_convert)
		
	var file := File.new()
	file.open("user://level_list/converted", File.WRITE)
	file.close()
		
	call_deferred("on_conversion_finished")
	
func start_file_timer(file_path: String):
	current_file = file_path
	thread_timer = 0.0
	
	var file := File.new()
	if file.open(file_path, File.READ) == OK:
		var length: float = file.get_len()
		thread_timeout = 2.0 + (length / TIMEOUT_FACTOR)
		file.close()
	else:
		thread_timeout = 2.0

func finish_file(file_path: String):
	progress_bar.value += 1
	progress_label.text = str(stepify(progress_bar.value / progress_bar.max_value, 0.01) * 100).pad_decimals(2) + "%"
	files_to_convert.erase(file_path)

func on_conversion_finished():
	if conversion_thread and conversion_thread.is_active():
		conversion_thread.wait_to_finish()
	prints("Conversion complete. Files that failed:", failed_files)
	thread_timer_on = false
	
	progress_label.text = "Done!"
	status_label.text = status_done
	if not OS.has_feature("JavaScript"):
		call_deferred("emit_signal", "conversion_done")
	
	LocalSettings.change_setting("Meta", "game_version", Singleton.PlayerSettings.game_version)
	#owner.transition("MainMenu")
	
	level_list_util.init_levels_list()

func get_files_for_conversion():
	var dir := Directory.new()
	
	var skip_dir: PoolStringArray = ["assets", "Developer Levels", "saves", "music"]
	var nested_dir: Array = ["user://level_list_old"]
	var saves_to_convert: Array = ["user://level_list_old/Developer Levels/saves"]
	var thumbnails_to_convert: Array = ["user://level_list_old/Developer Levels/thumbnails"]
	var found_files: Array = []
	
	while not nested_dir.empty():
		var current_path: String = nested_dir.pop_back()
		if dir.open(current_path) != OK:
			continue
			
		dir.list_dir_begin(true, true)
		var file_name: String = dir.get_next()
		
		while file_name != "":
			var full_path: String = current_path.plus_file(file_name)
			
			if dir.current_is_dir():
				if file_name == "saves":
					saves_to_convert.append(dir.get_current_dir().plus_file("saves"))
				if file_name == "thumbnails":
					thumbnails_to_convert.append(dir.get_current_dir().plus_file("thumbnails"))
				elif not file_name in skip_dir:
					nested_dir.append(full_path)
			elif file_name.get_extension() == "127level":
				found_files.append(full_path)
			elif "sort" in file_name:
				var dest_path: String = full_path.replace("level_list_old", "level_list")
				var dest_dir: String = dest_path.get_base_dir()
				
				if not dir.dir_exists(dest_dir): dir.make_dir_recursive(dest_dir)
				
				dir.copy(full_path, dest_path)
				
			file_name = dir.get_next()
			
		dir.list_dir_end()
			
	return [found_files, saves_to_convert, thumbnails_to_convert]

func convert_inner(data: Array):
	var dir := Directory.new()

	for old in data:
		old = old as String
		var new: String = old.replace("level_list_old", "level_list")
		if not dir.dir_exists(new): dir.make_dir_recursive(new)
		
		if dir.open(old) == OK:
			dir.list_dir_begin(true, true)
			
			var file_name: String = dir.get_next()
			
			while file_name != "":

				dir.copy(old.plus_file(file_name), new.plus_file(file_name))
				file_name = dir.get_next()
				
			dir.list_dir_end()

func remove_recursive(path: String) -> int:
	var dir = Directory.new()
	if not dir.dir_exists(path):
		return FAILED
	
	var err = dir.open(path)
	if err != OK:
		return err
	
	dir.list_dir_begin(true, true) 
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path.plus_file(file_name)
		if dir.current_is_dir():
			remove_recursive(full_path)
		else:
			OS.move_to_trash(full_path)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return OS.move_to_trash(path)
