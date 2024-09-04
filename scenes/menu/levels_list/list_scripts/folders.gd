extends Node

signal folder_renamed(new_path)
signal folder_changed(new_path)

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


func change_folder(path: String, do_transition: bool = true, is_return: bool = false, auto_save: bool = true):
	if do_transition:
		list_handler.level_list.transition("LevelList")	
		# waits for the transition to finish so as to keep everything looking smooth :3
		yield(list_handler.level_list, "screen_change")
	
	
	var loader: Node = list_handler.loader
	if loader.level_load_thread.is_active():
		loader.halt_thread = true
		loader.level_load_thread.wait_to_finish()

	var old_folder: String = list_handler.working_folder
	if auto_save:
		list_handler.sorting.save_to_json(old_folder)
	list_handler.working_folder = path
	list_handler.clear_grid()
	
	# this adds a button unrelated to everything else
	# that returns you to the previous folder, but we
	# don't want this if you're already in the base folder!!
	list_handler.back_buttons = 0
	list_handler.folder_buttons = 0
	if is_return:
		list_handler.folder_stack.pop_back()
	
	if path != list_handler.BASE_FOLDER:
		var return_subtract = 2 if is_return else 1
		var parent_folder: String = list_handler.folder_stack[list_handler.folder_stack.size() - return_subtract]
		
		#print("Parent: " + parent_folder)
		#print("Current: " + list_handler.working_folder)
		#print(is_return)
		loader.add_folder_button(parent_folder, "Back...", true, true)
		list_handler.back_buttons = 1
		
	if not is_return:
		list_handler.folder_stack.push_back(list_handler.working_folder)

	#print(list_handler.folder_stack)
	
	load_folder(path)

func load_folder(path: String):
	var sorting: Node = list_handler.sorting
	var loader: Node = list_handler.loader
	
	sorting.load_from_json(path)
	loader.start_level_loading(path)
	list_handler.folder_buttons += sorting.sort.folders.size()
	
	emit_signal("folder_changed", path)

func rename_folder(old_path: String, new_path: String):
	# this is all the renaming stuff right here
	saved_levels_util.move_file(old_path, new_path)
	list_handler.working_folder = new_path
	
	# all of this is to update the parent's sort json to reflect the new name
	var old_name: String = saved_levels_util.get_last_in_path(old_path)
	var new_name: String = saved_levels_util.get_last_in_path(new_path)
	
	var folder_stack: Array = list_handler.folder_stack
	var parent_folder: String = folder_stack[folder_stack.size() - 2]
	var sorting: Node = list_handler.sorting
	sorting.save_to_json(list_handler.working_folder)
	
	sorting.load_from_json(parent_folder)
	var index: int = sorting.sort.folders.find(old_name)
	if index == -1: 
		push_error("Folder " + old_name + " not found in parent's sort.json file.")
		return
	
	folder_stack[folder_stack.size() - 1] = new_path
	sorting.sort.folders[index] = new_name
	sorting.save_to_json(parent_folder)
	
	sorting.load_from_json(list_handler.working_folder)
	
	# oh and toss this out for anyone who wants it
	emit_signal("folder_renamed", new_path)


func delete_current_folder():
	var parent_folder = list_handler.folder_stack[list_handler.folder_stack.size() - 2]
	
	var sorting: Node = list_handler.sorting
	sorting.load_from_json(parent_folder)
	
	sorting.sort.folders.erase(saved_levels_util.get_last_in_path(list_handler.working_folder))
	saved_levels_util.delete_file(list_handler.working_folder)
	
	sorting.save_to_json(parent_folder)
	change_folder(parent_folder, true, true, false)
