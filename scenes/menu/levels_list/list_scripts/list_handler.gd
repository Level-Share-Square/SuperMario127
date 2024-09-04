extends Node

## this entire line of logic gets
## pretty complicated!! to make it more manageable,
## i split it up into several scripts in separate nodes
## this way, its easier to find what functionality happens where

## oh!! and a message for any of the solar team, if they happen
## to start looking at this code to try and adapt it; DON'T
## this is my first time making anything like this, so it turned
## out less clean and concise than i was hoping. if i had to make
## this kind of thing again for another project, i'd probably
## rethink how to structure it since it feels a bit tangled right now

### COMMON NODES
export var level_grid_path: NodePath
onready var level_grid := get_node(level_grid_path)

export var level_list_path: NodePath
onready var level_list := get_node(level_list_path)

export var level_panel_path: NodePath
onready var level_panel := get_node(level_panel_path)

export var focus_path: NodePath
onready var focus := get_node(focus_path)

export var old_levels_path: NodePath
onready var old_levels := get_node(old_levels_path)

### sub-scripts
onready var loader: Node  = $Loader
onready var saver: Node = $Saver
onready var sorting: Node = $Sorting
onready var folders: Node = $Folders
onready var thumbnail_cache: Node = $ThumbnailCache

### variables
const BASE_FOLDER: String = "user://level_list"
const DEFAULT_LEVEL: String = "res://level/default_level.tres"

var working_folder: String = BASE_FOLDER
# back buttons take most recent folder from the stack and pop it
# while folder buttons push a new folder to the stack
var folder_stack: Array = [BASE_FOLDER]

var back_buttons: int = 0
var folder_buttons: int = 0

func _ready():
	yield(get_owner(), "screen_opened")
	
	level_grid.connect("child_entered_tree", self, "auto_change_focus")
	
	folders.create_folder(working_folder)
	if old_levels.should_convert_levels():
		old_levels.start(BASE_FOLDER)
		yield(old_levels, "conversion_complete")
	
	folders.load_folder(working_folder)

func clear_grid():
	for child in level_grid.get_children():
		child.queue_free()

# the auto is there so i can connect a signal which provides the most recent node as an argument
# without it actually picking the most recently added node
func auto_change_focus(focus_node = null): change_focus()
func change_focus(focus_node = null):
	if !is_instance_valid(focus_node): 
		focus_node = level_grid.get_child(0)
	focus.default_focus = focus_node


func insert_folder():
	var folder_name = "New Folder"
	folder_name = folders.get_valid_folder_name(folder_name, working_folder)
	
	folders.create_folder(working_folder + "/" + folder_name)
	
	sorting.add_to_list(folder_name, "folders")
	sorting.save_to_json(working_folder)
	
	loader.add_folder_button(working_folder + "/" + folder_name, folder_name, true)

func insert_level(level_code: String = ""):
	if level_code == "":
		level_code = saved_levels_util.load_level_code_file(DEFAULT_LEVEL)
	
	var level_id: String = saver.generate_level_id()
	saver.save_level(level_code, level_id, working_folder)
	loader.add_level_card(working_folder + "/" + level_id + ".127level", level_id, working_folder, level_code, true)

func remove_level(level_id: String):
	saver.delete_level(level_id, working_folder)
	level_grid.get_node(level_id).call_deferred("queue_free")
