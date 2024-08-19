extends VBoxContainer

export var folder_name_edit_path: NodePath
onready var folder_name_edit: LineEdit = get_node(folder_name_edit_path)

export var folder_name_label_path: NodePath
onready var folder_name_label: Label = get_node(folder_name_label_path)

export var list_handler_path: NodePath
onready var list_handler: Node = get_node(list_handler_path)

func rename_folder():
	var folder_name: String = folder_name_edit.text
	
	var regex = RegEx.new()
	regex.compile("[^A-Za-z0-9 ]")
	
	var result: RegExMatch = regex.search(folder_name)
	if result:
		print("Invalid folder name. Offending character: " + result.get_string())
		return
	
	var folder_path: String = (
		list_handler.folder_stack[list_handler.folder_stack.size() - 2] + "/" + folder_name
	)
	
	if saved_levels_util.dir_exists(folder_path): 
		print("Folder already exists.")
		return
	
	list_handler.folders.rename_folder(
		list_handler.list_handler.working_folder,
		folder_path
	)
	folder_name_edit.text = ""

func delete_folder():
	list_handler.folders.delete_current_folder()

func update_folder_name(new_path: String):
	if !is_instance_valid(folder_name_label): return
	folder_name_label.text = saved_levels_util.get_last_in_path(new_path)
