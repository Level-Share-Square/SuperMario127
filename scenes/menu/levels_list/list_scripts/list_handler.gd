extends Node

## this entire line of logic gets
## pretty complicated!! to make it more manageable,
## i split it up into several scripts in separate nodes
## this way, its easy to find what functionality happens where

### COMMON NODES
export var level_grid_path: NodePath
onready var level_grid = get_node(level_grid_path)

export var level_list_path: NodePath
onready var level_list := get_node(level_list_path)

export var level_panel_path: NodePath
onready var level_panel := get_node(level_panel_path)

### sub-scripts
onready var loader: Node  = $Loader
onready var saver: Node = $Saver
onready var sorting: Node = $Sorting
onready var folders: Node = $Folders

### variables
const BASE_FOLDER: String = "user://level_list"
const DEFAULT_LEVEL: String = "res://level/default_level.tres"
var working_folder: String = BASE_FOLDER
var folder_buttons: int = 0

func _ready():
	folders.create_folder(working_folder)
	folders.load_folder(working_folder)

func clear_grid():
	for child in level_grid.get_children():
		child.queue_free()


func insert_folder():
	var folder_name = "New Folder"
	folder_name = folders.get_valid_folder_name(folder_name, working_folder)
	
	folders.create_folder(working_folder + "/" + folder_name)
	
	sorting.add_to_list(folder_name, "folders")
	sorting.save_to_json(working_folder)

func insert_level(level_code: String = ""):
	if level_code == "":
		level_code = loader.level_code_from_file(DEFAULT_LEVEL)
	
	var level_id: String = saver.generate_level_id()
	saver.save_level(level_code, level_id, working_folder)
	loader.add_level_card(working_folder + "/" + level_id + ".127level", level_id, level_code, true)

func remove_level(level_id: String):
	saver.delete_level(level_id, working_folder)
	level_grid.get_node(level_id).call_deferred("queue_free")
