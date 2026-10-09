class_name LevelCard
extends BaseCard


## passed nodes
var http_thumbnails: HTTPThumbnails

## internal
var is_campaign: bool
var has_save: bool
var is_valid: bool

var level_metadata: LevelMetadata
var level_save_data: LevelSaveData


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
	# if it's still empty, this code just isn't valid at all
	if level_code == "":
		is_valid = false
		return
	
	level_metadata = LevelCodeDeserializer.deserialize_level_metadata_code(LevelCodeTokenizer.splice_metadata(level_code))
	is_valid = true
	
	if is_campaign: return
	
	# load save file
	level_save_data = LevelSaveData.new(id, parent_folder, level_metadata.collectible_data)
	var save_path: String = level_list_util.get_level_save_path(id, parent_folder, -1)
	if level_list_util.file_exists(save_path):
		has_save = true
		
