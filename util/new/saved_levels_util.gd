class_name saved_levels_util


const BASE_FOLDER: String = "user://level_list"
const ENCRYPTION_PASSWORD = "BadCode"


## MISC
static func file_exists(file_path: String) -> bool:
	var file := File.new()
	return file.file_exists(file_path)

static func dir_exists(dir_path: String) -> bool:
	var directory := Directory.new()
	return directory.dir_exists(dir_path)

static func delete_file(file_path: String):
	var err: int = OS.move_to_trash(ProjectSettings.globalize_path(file_path))
	if err != OK:
		push_error("Failure deleting level file. Error code: " + str(err))

static func move_file(file_path: String, new_path: String):
	var directory := Directory.new()
	var err: int = directory.rename(file_path, new_path)
	if err != OK:
		push_error("Failure moving file/directory. Error code: " + str(err))

# this retrieves everything after the last "/" in the file path
static func get_last_in_path(file_path: String) -> String:
	var path_array: PoolStringArray = file_path.split("/")
	return path_array[path_array.size() - 1]

static func generate_level_id() -> String:
	return uuid_util.v4()


## LEVEL CODES
static func get_level_file_path(level_id: String, working_folder: String) -> String:
	return working_folder + "/" + level_id + ".127level"

static func load_level_code_file(file_path: String) -> String:
	var file := File.new()
	var err: int = file.open(file_path, File.READ)
	if err != OK:
		push_error("File " + file_path + " failed to load. Error code: " + str(err))
	
	var level_code: String = file.get_as_text()
	file.close()
	
	return level_code

static func save_level_code_file(level_code: String, file_path: String):
	var file := File.new()
	var err: int = file.open(file_path, File.WRITE)
	if err != OK:
		push_error("File " + file_path + " could not be saved. Error code: " + str(err))
	
	file.store_string(level_code)
	file.close()


## SAVE FILES
static func get_level_save_path(level_id: String, working_folder: String) -> String:
	return working_folder + "/saves/" + level_id + ".127save"

static func load_level_save_file(file_path: String) -> Dictionary:
	var file := File.new()
	var err: int = file.open_encrypted_with_pass(file_path, File.READ, ENCRYPTION_PASSWORD)
	if err != OK:
		push_error("File " + file_path + " failed to load. Error code: " + str(err))
	
	var parse: JSONParseResult = JSON.parse(file.get_as_text())
	file.close()
	
	if parse.error != OK:
		push_error(parse.error_string)
		return {}
		
	return parse.result

static func save_level_save_file(level_save: Dictionary, file_path: String):
	var save_json: String = JSON.print(level_save)
	
	var file := File.new()
	var err: int = file.open_encrypted_with_pass(file_path, File.WRITE, ENCRYPTION_PASSWORD)
	if err != OK:
		push_error("File " + file_path + " could not be saved. Error code: " + str(err))
	
	file.store_string(save_json)
	file.close()

## THUMBNAILS
const EXTENSIONS = [
	".png",
	".jpeg"
]
static func get_level_thumbnail_path(level_id: String, working_folder: String) -> String:
	var path: String = working_folder + "/thumbnails/" + level_id
	
	for extension in EXTENSIONS:
		if file_exists(path + extension):
			return path + extension
	return path

static func get_image_from_path(file_path: String) -> ImageTexture:
	var image := Image.new()
	var err: int = image.load(file_path)
	if err != OK:
		push_error("Error loading image at path " + file_path + ". Error code: " + str(err))
	 
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	return texture


## MUSIC
static func get_level_music_path(level_id: String, area_id: int, working_folder: String) -> String:
	return get_level_music_folder(working_folder) + level_id + "-" + str(area_id) + ".ogg"

static func get_level_music_folder(working_folder: String) -> String:
	return working_folder + "/music/"

## AUTOSAVES
static func autosave_level_to_disk(level_code: String, level_path: String):
	var file := File.new()
	var err: int = file.open(level_path, File.WRITE)
	if err != OK: 
		push_error("File " + level_path + " failed to save. Error code: " + str(err))
	
	var time = Time.get_unix_time_from_system()
	file.store_string(str(time) + "\n")
	file.store_string(level_code)
	file.close()
