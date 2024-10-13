class_name level_list_util


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

static func generate_level_id() -> String:
	return uuid_util.v4()


static func move_level_files(level_id: String, working_folder: String, new_folder: String):
	sort_file_util.remove_from_sort(level_id, working_folder, sort_file_util.LEVELS)
	sort_file_util.add_to_sort(level_id, new_folder, sort_file_util.LEVELS)

	var file_path: String = get_level_file_path(level_id, working_folder)
	var new_file_path: String = get_level_file_path(level_id, new_folder)
	move_file(file_path, new_file_path)
	
	var save_path: String = get_level_save_path(level_id, working_folder)
	var new_save_path: String = get_level_save_path(level_id, new_folder)
	if file_exists(save_path):
		move_file(save_path, new_save_path)
	
	var thumbnail_path: String = get_level_thumbnail_path(level_id, working_folder)
	var new_thumbnail_path: String = get_level_thumbnail_path(level_id, new_folder)
	if file_exists(thumbnail_path):
		move_file(thumbnail_path, new_thumbnail_path)
	
	var music_folder: String = get_level_music_folder(working_folder)
	var new_music_folder: String = get_level_music_folder(new_folder)
	var directory := Directory.new()
	if directory.open(music_folder) == OK:
		directory.list_dir_begin(true)
		
		var file: String = directory.get_next()
		while file != "":
			if file.begins_with(level_id):
				move_file(music_folder + "/" + file, new_folder + "/" + file)
			file = directory.get_next()
	
	var lss_id: String = lss_link_util.get_id_from_path(file_path)
	if lss_id != "":
		lss_link_util.remove_level_from_link(lss_id)
		lss_link_util.add_level_to_link(lss_id, new_file_path)


static func wipe_level_files(level_id: String, working_folder: String):
	sort_file_util.remove_from_sort(level_id, working_folder, sort_file_util.LEVELS)
	
	var file_path: String = get_level_file_path(level_id, working_folder)
	delete_file(file_path)
	
	var save_path: String = get_level_save_path(level_id, working_folder)
	if file_exists(save_path):
		delete_file(save_path)

	var thumbnail_path: String = get_level_thumbnail_path(level_id, working_folder)
	if file_exists(thumbnail_path):
		delete_file(thumbnail_path)
	
	var music_folder: String = get_level_music_folder(working_folder)
	var directory := Directory.new()
	if directory.open(music_folder) == OK:
		directory.list_dir_begin(true)
		
		var file: String = directory.get_next()
		while file != "":
			if file.begins_with(level_id):
				delete_file(music_folder + "/" + file)
			file = directory.get_next()
	
	var lss_id: String = lss_link_util.get_id_from_path(file_path)
	if lss_id != "":
		lss_link_util.remove_level_from_link(lss_id)
	

## FOLDERS
static func get_folder_path(folder_id: String, parent_folder: String) -> String:
	return parent_folder + "/" + folder_id

static func get_valid_folder_name(folder_id: String, parent_folder: String) -> String:
	var dir := Directory.new()
	if dir.dir_exists(parent_folder + "/" + folder_id):
		return get_valid_folder_name(folder_id + "_", parent_folder)
	return folder_id

static func get_parent_from_path(file_path: String):
	var index: int = file_path.rfind("/")
	return file_path.substr(0, index)

# this retrieves everything after the last "/" in the file path
static func get_last_in_path(file_path: String) -> String:
	var index: int = file_path.rfind("/")
	return file_path.substr(index + 1)

static func create_level_folder(path: String):
	var dir := Directory.new()
	if !dir.dir_exists(path):
		#warning-ignore:return_value_discarded
		dir.make_dir(path)
	else:
		return # not worth wasting time on the rest then
		
	if !dir.dir_exists(path + "/saves"):
		#warning-ignore:return_value_discarded
		dir.make_dir(path + "/saves")

	if !dir.dir_exists(path + "/thumbnails"):
		#warning-ignore:return_value_discarded
		dir.make_dir(path + "/thumbnails")

	if !dir.dir_exists(path + "/music"):
		#warning-ignore:return_value_discarded
		dir.make_dir(path + "/music")
	
	sort_file_util.save_sort_file(path, {})


static func delete_level_folder(path: String):
	var parent_folder: String = get_parent_from_path(path)
	var folder_id: String = get_last_in_path(path)
	sort_file_util.remove_from_sort(folder_id, parent_folder, sort_file_util.FOLDERS)
	delete_file(path)


static func rename_level_folder(path: String, new_id: String):
	var parent_folder: String = get_parent_from_path(path)
	var folder_id: String = get_last_in_path(path)
	
	sort_file_util.remove_from_sort(folder_id, parent_folder, sort_file_util.FOLDERS)
	sort_file_util.add_to_sort(new_id, parent_folder, sort_file_util.FOLDERS)
	
	move_file(path, get_folder_path(new_id, parent_folder))


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
	".jpg"
]
static func get_level_thumbnail_path(level_id: String, working_folder: String, add_extension: bool = true) -> String:
	var path: String = working_folder + "/thumbnails/" + level_id
	
	if add_extension:
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
