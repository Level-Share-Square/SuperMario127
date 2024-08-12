extends VBoxContainer

export var level_code_path: NodePath
onready var level_code_edit: Node = get_node(level_code_path)

export var list_handler_path: NodePath
onready var list_handler: Node = get_node(list_handler_path)

func import_level_code():
	list_handler.insert_level(level_code_edit.text)
	
	level_code_edit.text = ""
	level_code_edit.clear_undo_history()
