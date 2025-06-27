class_name LevelCard
extends BaseCard


## passed nodes
var http_thumbnails: HTTPThumbnails

## internal
var level_info: LevelInfo
var is_campaign: bool
var has_save: bool


func pass_nodes(
	_list_handler: LevelListHandler,
	_drag_cursor: Area2D,
	_http_thumbnails: HTTPThumbnails
):
	list_handler = _list_handler
	drag_cursor = _drag_cursor
	http_thumbnails = _http_thumbnails


func setup(
	_id: String, 
	_parent_folder: String,
	_can_sort: bool,
	_move_to_front: bool,
	level_code: String = "",
	_is_campaign: bool = false
):
	sort_type = sort_file_util.LEVELS
	can_sort = _can_sort
	move_to_front = _move_to_front
	is_campaign = _is_campaign
	
	id = _id
	name = id
	parent_folder = _parent_folder
	
	# load level info
	var file_path: String = level_list_util.get_level_file_path(id, parent_folder)
	if level_code == "":
		level_code = level_list_util.load_level_code_file(file_path)
#	elif not level_code_util.fast_is_valid(level_code):
#		level_code = level_list_util.load_level_code_file(LevelData.DEFAULT_CODE_PATH)
	
	level_info = LevelInfo.new(id, parent_folder, level_code)
	
	# Uncomment the lines below and above to have any invalid level code be replaced by the default level code
	# For now it just shows a predefined invalid level card that doesn't let you edit or play the level
#	if (level_info.level_name == "\"Invalid Level\""):
#		level_code = level_list_util.load_level_code_file(LevelData.DEFAULT_CODE_PATH)
#		level_info = LevelInfo.new(id, parent_folder, level_code)
	
	# load save file
	var save_path: String = level_list_util.get_level_save_path(id, parent_folder)
	if level_list_util.file_exists(save_path):
		level_info.load_save_from_dictionary(level_list_util.load_level_save_file(save_path))
		has_save = true
