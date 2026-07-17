class_name Selector
extends EditorTool

const TILE_SIZE: int = 32
const TILE := Vector2(TILE_SIZE, TILE_SIZE)

export var animation_delay: float = 6
export var frame_count: int = 5

onready var highlight = get_node("%Highlight")
onready var selection_box = get_node("%SelectionBox")
onready var camera = $"%EditorCamera"

var is_dragging: bool = false
var pasted: bool = false

var fill_rect: Rect2
var start_pos: Vector2
var mouse_pos: Vector2
var timer = 0

signal mouse_motion(position)

func _ready():
	highlight.hide()
	selection_box.hide()

func get_tile_grid_position(vector: Vector2):
	return vector.snapped(TILE) / TILE_SIZE
	
func get_mouse_grid_position():
	return get_tile_grid_position(get_global_mouse_position())
	
func get_adjusted_mouse_position():
	return get_global_mouse_position().snapped(TILE)
	
func is_on_tile_grid(position: Vector2):
	var tolerance = TILE_SIZE/4
	return position.distance_to(((position / TILE_SIZE).round() * TILE_SIZE)) < tolerance
	
func _click_left(event, mouse_position):
	var adjusted_mouse_position = get_adjusted_mouse_position()
	if !fill_rect.has_point(adjusted_mouse_position):
		is_dragging = true
		set_highlight_mode(true)
		reset_bounds()
		start_pos = adjusted_mouse_position
		on_selection_outside_clicked()
	else:
		on_selection_inside_clicked()
		
func _click_left_released(event, mouse_position):
	is_dragging = false
	emit_signal("mouse_motion", null)
	set_highlight_mode(false)
	on_mouse_released()
	
func _mouse_movement(event, mouse_position):
	var adjusted_mouse_position = get_adjusted_mouse_position()
	if mouse_pos != adjusted_mouse_position:
		emit_signal("mouse_motion", adjusted_mouse_position)
		mouse_pos = adjusted_mouse_position
	if is_dragging:
		box_expansion()
			
func set_highlight_mode(value: bool):
	highlight.visible = value
	selection_box.visible = !value
	
func hide_visuals():
	highlight.visible = false
	selection_box.visible = false
	
func reset_bounds():
	highlight.rect_global_position = Vector2.ZERO
	highlight.rect_size = Vector2.ZERO
	selection_box.rect_global_position = Vector2.ZERO
	selection_box.rect_size = Vector2.ZERO
	fill_rect = Rect2(0, 0, 0, 0)

func _process(delta):
	timer = max(timer - 1, 0)

	if timer <= 0:
		selection_box.region_rect.position.x = wrapi(
			selection_box.region_rect.position.x + selection_box.region_rect.size.x,
			0,
			frame_count * selection_box.region_rect.size.x
		)
		timer = animation_delay

func box_expansion():
	var drag_rect := Rect2(start_pos, get_adjusted_mouse_position() - start_pos).abs()
	
	highlight.rect_global_position = drag_rect.position
	highlight.rect_size = drag_rect.size
	
	selection_box.rect_global_position = drag_rect.position
	selection_box.rect_size = drag_rect.size
	
	fill_rect = drag_rect
	
# Callbacks

func on_selection_inside_clicked():
	pass
	
func on_selection_outside_clicked():
	pass
	
func on_mouse_move():
	pass
	
func on_mouse_clicked():
	pass
	
func on_mouse_released():
	if min(fill_rect.size.x, fill_rect.size.y) < TILE_SIZE:
		reset_bounds()
		hide_visuals()
		return false
	return true



#func _on_Paste_pressed():
#	if editor.tool_manager.current_tool == self:
#		var result = JSON.parse(OS.get_clipboard()).result
#		var raw_tiles = result[0]
#		var tiles: Dictionary
#		for tile_pos in raw_tiles:
#			tiles[get_tile_grid_position((old_value_util.decode_value(tile_pos) + camera.position))/32] = raw_tiles[tile_pos]
#		if typeof(tiles) == TYPE_DICTIONARY:
#			pasted = true
#			editor.selected_tiles = tiles
#			set_initial_buffer()
#			selection_box.show()
#			selection_box.rect_position = get_tile_grid_position(old_value_util.decode_value(result[1][0]) + camera.position)
#			selection_box.rect_scale = old_value_util.decode_value(result[1][1])
#			selection_box.rect_size = old_value_util.decode_value(result[1][2])
#			selection_box.rect_rotation = result[1][3]
#
#
#func _on_Copy_button_down():
#	if editor.tool_manager.current_tool == self:
#		var tiles: Dictionary
#		for tile_pos in editor.selected_tiles:
#			tiles[old_value_util.encode_value(tile_pos*32 - camera.position)] = editor.selected_tiles[tile_pos]
#		OS.set_clipboard(JSON.print([tiles, [old_value_util.encode_value(Vector2(round(selection_box.rect_position.x - camera.position.x), round(selection_box.rect_position.y - camera.position.y))), old_value_util.encode_value(selection_box.rect_scale), old_value_util.encode_value(selection_box.rect_size), selection_box.rect_rotation]]))
#
#
#
#func _on_Delete_button_down():
#	if editor.tool_manager.current_tool == self:
#		var action := PlaceTilesAction.new()
#		action.shared = shared
#		action.layer = editor.layer
#		action.tileset_id = 0
#		action.tile_id = 0
#		action.palette = 0
#		action.do_tiles = editor.selected_tiles.keys()
#		editor.action_manager.commit_action(action)
#		editor.selected_tiles = {}
