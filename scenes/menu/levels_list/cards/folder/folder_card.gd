class_name FolderCard
extends BaseCard


var is_back: bool


func pass_nodes(
	_list_handler: LevelListHandler,
	_drag_cursor: Area2D
):
	list_handler = _list_handler
	drag_cursor = _drag_cursor


func setup(
	_id: String, 
	_parent_folder: String,
	_can_sort: bool,
	_move_to_front: bool,
	_is_back: bool = false
):
	id = _id
	parent_folder = _parent_folder
	
	sort_type = sort_file_util.FOLDERS
	can_sort = _can_sort
	move_to_front = _move_to_front
	is_back = _is_back


func card_dragged(card: BaseCard):
	if card == self: return
	
	if card is LevelCard:
		level_list_util.move_level_files(
			card.id, 
			card.parent_folder, 
			get_folder_path()
		)
		card.call_deferred("queue_free")
		print("meow")
	else:
		print("This card type cannot be moved into a folder card.")


func get_folder_path() -> String:
	if not is_back:
		return level_list_util.get_folder_path(id, parent_folder)
	return parent_folder
