extends Control


const TILE_SIZE: int = 32


onready var editor: Node = get_owner()
onready var drag: ColorRect = $Drag


var selected_box: Node

var editing_layer: int
var placing_button: int

var initial_pos: Vector2
var mouse_pos: Vector2
var mouse_tile_pos: Vector2

var left_down: bool
var right_down: bool

var left_last_down: bool
var right_last_down: bool


func place_tiles():
	var select_start: Vector2 = (initial_pos / 32).round()
	var select_end: Vector2 = mouse_tile_pos
	
	var fill_pos := Vector2(
		min(select_start.x, select_end.x),
		min(select_start.y, select_end.y))
	var fill_size := Vector2(
		max(select_start.x - select_end.x, select_end.x - select_start.x),
		max(select_start.y - select_end.y, select_end.y - select_start.y))
	var fill := Rect2(fill_pos, fill_size)
	
	for y_offset in fill.size.y:
		for x_offset in fill.size.x:
			var offset := Vector2(x_offset, y_offset)
			set_tile(fill.position + offset)


func set_tile(pos: Vector2):
	var item = selected_box.item
	var shared = editor.shared
	
	if not item.on_place(pos, editor.level_data, editor.level_area): return
	if not editor.level_area.settings.bounds.has_point(pos+Vector2(0.5,0.5)): return
	
	
	var tileset_id: int = item.tileset_id if placing_button == 0 else 0
	var tile_id: int = item.tile_id if placing_button == 0 else 0
	var palette_index: int = item.palette_index if placing_button == 0 else 0
	
	var last_tile = shared.get_tile(pos.x, pos.y, editing_layer)
	
	editor.tiles_stack.append([pos.x, pos.y, editing_layer, last_tile, [tileset_id, tile_id]])
	shared.set_tile(pos.x, pos.y, editing_layer, tileset_id, tile_id, palette_index)



func selected_update():
	if selected_box.item.is_object: return
	
	
	if drag.visible:
		var drag_size: Vector2 = (mouse_tile_pos * TILE_SIZE) - initial_pos
		
		drag.rect_size = drag_size.abs()
		drag.rect_scale = drag_size.sign()
		
	
	## input
	
	if left_down and not left_last_down:
		placing_button = 0
		mouse_down()
	elif right_down and not right_last_down:
		placing_button = 1
		mouse_down()
	
	if not left_down and left_last_down: mouse_up()
	if not right_down and right_last_down: mouse_up()
	
	left_last_down = left_down
	right_last_down = right_down


func mouse_down() -> void:
	initial_pos = mouse_tile_pos * TILE_SIZE
	
	drag.rect_position = initial_pos
	drag.rect_size = Vector2.ZERO
	drag.visible = true


func mouse_up() -> void:
	drag.visible = false
	if drag.rect_size.x < TILE_SIZE or drag.rect_size.y < TILE_SIZE: return
	
	place_tiles()
