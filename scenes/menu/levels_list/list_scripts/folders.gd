extends Node

onready var list_handler = get_parent()
onready var dir := Directory.new()

func get_valid_folder_name(folder_name: String, path: String) -> String:
	if dir.dir_exists(path + "/" + folder_name):
		return get_valid_folder_name(folder_name + "_", path)
	
	return folder_name

func create_folder(path: String):
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
	
	var sorting: Node = list_handler.sorting
	sorting.save_to_json(path, true)


func change_folder(path: String, do_transition: bool = true):
	var loader: Node = list_handler.loader
	if loader.level_load_thread.is_alive(): return
	
	if do_transition:
		list_handler.level_list.transition("LevelList")	
		# waits for the transition to finish so as to keep everything looking smooth :3
		yield(list_handler.level_list, "screen_change")
	
	
	var old_folder: String = list_handler.working_folder
	
	list_handler.sorting.save_to_json(old_folder)
	list_handler.working_folder = path
	list_handler.clear_grid()
	
	# this adds a button unrelated to everything else
	# that returns you to the previous folder, but we
	# don't want this if you're already in the base folder!!
	list_handler.folder_buttons = 0
	if path != list_handler.BASE_FOLDER:
		loader.add_folder_button(old_folder, "Back...")
		list_handler.folder_buttons = 1
	
	load_folder(path)

func load_folder(path: String):
	var sorting: Node = list_handler.sorting
	var loader: Node = list_handler.loader
	
	sorting.load_from_json(path)
	loader.start_level_loading(path)
	list_handler.folder_buttons += sorting.sort.folders.size()
