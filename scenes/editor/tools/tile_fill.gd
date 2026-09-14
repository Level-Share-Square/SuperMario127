extends EditorTool

const MAX_DEPTH: int = 2000

var is_erasing: bool
var undo_tiles: Dictionary = {}

class ListNode:
	var value = null
	var next: ListNode = null
	var prev: ListNode = null
	
	func _init(val): value = val
	
class Queue:
	var head: ListNode = null
	var tail: ListNode = null
	var size: int = 0
	
	func append(val: Vector2):
		var new_node := ListNode.new(val)
		if not head: 
			head = new_node
			tail = new_node
		else:
			tail.next = new_node
			new_node.prev = tail
			tail = new_node
		size += 1
		
	func pop_front():
		if not head: return null
		
		var old_head = head
		head = head.next
		if head:
			head.prev = null
		else:
			tail = null
		size -= 1
		return old_head.value
		
	func is_empty(): return size == 0

func _click_left(_event: InputEvent, _world_pos: Vector2) -> void:
	is_erasing = tool_manager.is_erasing
	if editor.get_node("%FillConfirmWindow").visible: return
	draw_tile(get_mouse_tile_pos())
	
func _click_right(_event: InputEvent, _world_pos: Vector2) -> void:
	is_erasing = not tool_manager.is_erasing
	if editor.get_node("%FillConfirmWindow").visible: return
	draw_tile(get_mouse_tile_pos())

func draw_tile(pos: Vector2) -> void:
	undo_tiles = {}
	fill_place(pos.x, pos.y)
		

func fill_place(pos_x, pos_y):
	var item = editor.selected_item
	var tile_to_fill = shared.get_tile(pos_x, pos_y, editor.layer)
	var selected_tile = [item.tileset_id, item.tile_id, item.palette]
	var cells := Queue.new()
	cells.append(Vector2(pos_x, pos_y))

	var depth: int = 0
	while not cells.is_empty():
		if depth >= MAX_DEPTH:
			break
		var current_cell: Vector2 = cells.pop_front()
		if current_cell == null: break
		
		var first_tile = shared.get_tile(current_cell.x - 1, current_cell.y, editor.layer)
		if (first_tile == tile_to_fill and not is_erasing or first_tile != [0, 0, 0] and is_erasing) && not undo_tiles.has(Vector2(current_cell.x - 1, current_cell.y)):
			cache_tile(current_cell.x - 1, current_cell.y, first_tile)
			cells.append( Vector2(current_cell.x - 1, current_cell.y) )
	
		var second_tile = shared.get_tile(current_cell.x + 1, current_cell.y, editor.layer)
		if (second_tile == tile_to_fill and not is_erasing or second_tile != [0, 0, 0] and is_erasing) && not undo_tiles.has(Vector2(current_cell.x + 1, current_cell.y)):
			cache_tile(current_cell.x + 1, current_cell.y, second_tile)
			cells.append( Vector2(current_cell.x + 1, current_cell.y) )

		var third_tile = shared.get_tile(current_cell.x, current_cell.y - 1, editor.layer)
		if (third_tile == tile_to_fill and not is_erasing or third_tile != [0, 0, 0] and is_erasing) && not undo_tiles.has(Vector2(current_cell.x, current_cell.y - 1)):
			cache_tile(current_cell.x, current_cell.y - 1, third_tile)
			cells.append( Vector2(current_cell.x, current_cell.y - 1) )

		var fourth_tile = shared.get_tile(current_cell.x, current_cell.y + 1, editor.layer)
		if (fourth_tile == tile_to_fill and not is_erasing or fourth_tile != [0, 0, 0] and is_erasing) && not undo_tiles.has(Vector2(current_cell.x, current_cell.y + 1)):
			cache_tile(current_cell.x, current_cell.y + 1, fourth_tile)
			cells.append( Vector2(current_cell.x, current_cell.y + 1))
		
		depth += 1
	if depth >= MAX_DEPTH:
		prompt_place()
		return
	finalize_placement()

func cache_tile(pos_x, pos_y, tile):
	var cell := Vector2(pos_x, pos_y)
		
	undo_tiles.get_or_add(cell, tile)
	
func prompt_place():
	var window = editor.get_node("%FillConfirmWindow")
	
	window.toggle_window()
	window.set_tile_number(MAX_DEPTH)
	window.connect("choice_made", self, "handle_prompt_choice")
	
func handle_prompt_choice(choice):
	if choice:
		finalize_placement()
	else:
		pass

func finalize_placement() -> void:
	
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = editor.selected_item.tileset_id if not is_erasing else 0
	action.tile_id = editor.selected_item.tile_id if not is_erasing else 0
	action.palette = editor.selected_item.palette if not is_erasing else 0
	action.do_tiles = undo_tiles.keys()
	action.undo_tiles = undo_tiles.duplicate()
	editor.action_manager.commit_action([action])
	
	editor.tile_buffer.clear()
	undo_tiles.clear()

# Mouse coords to tile grid coords
func get_mouse_tile_pos() -> Vector2:
	return (get_mouse_pos() / editor.TILE_SIZE).floor()
	
	

