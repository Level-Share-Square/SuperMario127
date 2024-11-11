extends VBoxContainer


onready var list_handler: LevelListHandler = $"%ListHandler"

export var folder_name_edit_path: NodePath
onready var folder_name_edit: LineEdit = get_node(folder_name_edit_path)

export var folder_name_label_path: NodePath
onready var folder_name_label: Label = get_node(folder_name_label_path)


func rename_folder():
	var folder_name: String = folder_name_edit.text
	
	var regex = RegEx.new()
	regex.compile("[^A-Za-z0-9 ]")
	
	var result: RegExMatch = regex.search(folder_name)
	if result:
		print("Invalid folder name. Offending character: " + result.get_string())
		return
	
	var parent_path: String = level_list_util.get_parent_from_path(list_handler.working_folder)
	var folder_path: String = level_list_util.get_folder_path(folder_name, parent_path)
	if level_list_util.dir_exists(folder_path): 
		print("Folder already exists.")
		return
	
	level_list_util.rename_level_folder(list_handler.working_folder, folder_name)
	list_handler.working_folder = folder_path
	
	update_folder_name(folder_path)
	folder_name_edit.text = ""


func delete_folder():
	level_list_util.delete_level_folder(list_handler.working_folder)
	
	var parent_folder: String = level_list_util.get_parent_from_path(list_handler.working_folder)
	list_handler.loader.transition_to_directory(parent_folder)


func update_folder_name(new_path: String):
	if !is_instance_valid(folder_name_label): return
	folder_name_label.text = level_list_util.get_last_in_path(new_path)
