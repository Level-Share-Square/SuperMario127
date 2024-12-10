extends Node


signal loading_finished

onready var subscreens := $"%Subscreens"
onready var list_handler: LevelListHandler = $"%ListHandler"
onready var drag_cursor: Area2D = $"%DragCursor"
onready var http_thumbnails: HTTPThumbnails = $"%HTTPThumbnails"

onready var folder_card_scene: PackedScene = preload("res://scenes/menu/levels_list/cards/folder/folder_card.tscn")
onready var level_card_scene: PackedScene = preload("res://scenes/menu/levels_list/cards/level/level_card.tscn")
onready var level_load_thread := Thread.new()


#func thread_load_directory(working_folder: String):
#	if level_load_thread.is_active():
#		level_load_thread.wait_to_finish()
#
#	var err = level_load_thread.start(self, "load_directory", working_folder)
#	if err != OK:
#		printerr("Error starting level loading thread.")


func clear_level_queue():
	level_queue.clear()


func transition_to_directory(working_folder: String):
	if is_loading: 
		clear_level_queue()
	
	list_handler.parent_screen.transition("LevelView")
	yield(list_handler.parent_screen, "screen_change")
	load_directory(working_folder)


var is_loading: bool
func load_directory(working_folder: String):
	http_thumbnails.clear_queue()
	list_handler.clear_grid()
	
	list_handler.working_folder = working_folder
	list_handler.emit_signal("directory_changed", working_folder)
	
	var level_grid: GridContainer = list_handler.level_grid
	level_grid.connect("child_entered_tree", list_handler, "change_focus", [], CONNECT_ONESHOT)
	
	print("Loading directory " + working_folder + "...")
	is_loading = true
	
	var is_base_folder: bool = working_folder == level_list_util.BASE_FOLDER
	var is_dev_folder: bool = working_folder == level_list_util.DEV_FOLDER
	if not is_base_folder and not is_dev_folder:
		var parent_folder: String = level_list_util.get_parent_from_path(working_folder)
		# folder id is useless on back buttons :p
		add_folder_card("", parent_folder, false, false, true)
	
	var sort: Dictionary = sort_file_util.load_sort_file(working_folder)
	for folder in sort.get(sort_file_util.FOLDERS, []):
		add_folder_card(folder, working_folder, not is_dev_folder)
	for level in sort.get(sort_file_util.LEVELS, []):
		level_queue.append(level)

	load_next_queue_level(working_folder, not is_dev_folder)


var level_queue: Array
func load_next_queue_level(working_folder, can_sort):
	if level_queue.size() <= 0:
		print("Done loading levels in directory.")
		emit_signal("loading_finished")
		is_loading = false
		return
	
	if level_load_thread.is_active():
		level_load_thread.wait_to_finish()
	
	var err = level_load_thread.start(self, "thread_add_level_card", [
		level_queue.pop_front(), 
		working_folder, 
		can_sort
	])
	if err != OK:
		printerr("Error starting level loading thread.")


func thread_add_level_card(params: Array):
	var level_id: String = params[0]
	var working_folder: String = params[1]
	var can_sort: bool = params[2]
	var level_card: LevelCard = add_level_card(level_id, working_folder, can_sort)
	level_card.connect("ready", self, "load_next_queue_level", [working_folder, can_sort])


func add_folder_card(
	folder_id: String, 
	parent_folder: String,
	can_sort: bool,
	move_to_front: bool = false,
	is_back: bool = false
):
	var level_grid: GridContainer = list_handler.level_grid
	var card_node: FolderCard = folder_card_scene.instance()
	card_node.pass_nodes(
		list_handler,
		drag_cursor
	)
	card_node.setup(
		folder_id,
		parent_folder,
		can_sort,
		move_to_front,
		is_back
	)
	
	level_grid.call_deferred("add_child", card_node)


func add_level_card(
	level_id: String, 
	working_folder: String,
	can_sort: bool,
	move_to_front: bool = false,
	level_code: String = ""
) -> LevelCard:
	var level_grid: GridContainer = list_handler.level_grid
	var card_node: LevelCard = level_card_scene.instance()
	card_node.pass_nodes(
		list_handler,
		drag_cursor,
		http_thumbnails
	)
	card_node.setup(
		level_id,
		working_folder,
		can_sort,
		move_to_front,
		level_code
	)
	
	level_grid.call_deferred("add_child", card_node)
	return card_node
