extends Node

const LEVELS_DIRECTORY = "user://levels/"
const LEVEL_DISK_PATHS_PATH = LEVELS_DIRECTORY + "paths.json"
const ENCRYPTION_PASSWORD = "BadCode"

var levels : Array = [] # array of type LevelInfo
var levels_disk_paths : Array = [] # array of type String
var selected_level : int = -1 # -1 means no level is selected

# we can just reuse these objects for everything involving files, nothing will happen in parallel atm anyway
var file : File = File.new()
var directory : Directory = Directory.new()

func _ready() -> void:
	load_level_paths_from_disk()
	for level_path in levels_disk_paths:
		load_level_from_disk(level_path)

func generate_level_disk_path(level_info : LevelInfo) -> String:
	return LEVELS_DIRECTORY + "%s_%s.level" % [hash(level_info), hash(OS.get_datetime())]

func save_level_paths_to_disk() -> void:
	var levels_disk_paths_json = to_json(levels_disk_paths)

	if !directory.dir_exists(LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(LEVELS_DIRECTORY)

	var error_code = file.open(LEVEL_DISK_PATHS_PATH, File.WRITE)
	if error_code == OK:
		file.store_string(levels_disk_paths_json)
		file.close()

# returns an error code
func save_level_to_disk(level_info : LevelInfo, level_path : String) -> int:
	if !directory.dir_exists(LEVELS_DIRECTORY):
		var _error_code = directory.make_dir_recursive(LEVELS_DIRECTORY)

	var error_code = file.open_encrypted_with_pass(level_path, File.WRITE, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary = level_info.get_saveable_dictionary()
		var level_save_dictionary_json = to_json(level_save_dictionary)
		file.store_string(level_save_dictionary_json)
		file.close()
	return OK

func save_level_by_index(level_index : int) -> int:
	var level_info = levels[level_index]
	var level_path = levels_disk_paths[level_index]
	return save_level_to_disk(level_info, level_path)

func delete_level_from_disk(level_path : String) -> void:
	var _error_code = directory.remove(level_path)

func load_level_paths_from_disk() -> void:
	var error_code = file.open(LEVEL_DISK_PATHS_PATH, File.READ)
	if error_code == OK:
		var levels_disk_paths_json = file.get_line()
		levels_disk_paths = parse_json(levels_disk_paths_json)
		file.close()

func load_level_from_disk(level_path : String) -> void:
	var error_code = file.open_encrypted_with_pass(level_path, File.READ, ENCRYPTION_PASSWORD)
	if error_code == OK:
		var level_save_dictionary_json = file.get_line()
		var level_save_dictionary = parse_json(level_save_dictionary_json)

		var level_info = LevelInfo.new()
		level_info.load_from_dictionary(level_save_dictionary)

		levels.append(level_info)

		file.close()
