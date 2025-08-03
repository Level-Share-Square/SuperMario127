class_name TileSelection
extends EditorTool

const TILE_SIZE: int = 32
const TILE := Vector2(TILE_SIZE, TILE_SIZE)

export var animation_delay: float = 6
export var frame_count: int = 5

onready var highlight = $"%Highlight"
onready var selection_box = $"%SelectionBox"
onready var tools_manager = get_parent()
onready var item_actions = get_node("%ItemActions")
onready var camera = $"%EditorCamera"

var mouse_pos: Vector2
var tile_grid_pos: Vector2

var tile_grid_starting_pos: Vector2
var old_selected_tiles: Dictionary = {}

var is_moving: bool = true
var pasted: bool = false

var fill_rect: Rect2
var start_pos: Vector2
var timer = 0

func _ready():
	highlight.hide()
	selection_box.hide()

func get_tile_ver(vector: Vector2):
	return Vector2(int(vector.x / 32) * 32, int(vector.y / 32) * 32)

func _process(delta):
	timer = max(timer - 1, 0)

	if timer <= 0:
		selection_box.region_rect.position.x = wrapi(
			selection_box.region_rect.position.x + selection_box.region_rect.size.x,
			0,
			frame_count * selection_box.region_rect.size.x
		)
		timer = animation_delay

	mouse_pos = get_tile_ver(get_global_mouse_position())
	tile_grid_pos = mouse_pos/32
	if tools_manager.current_tool == self:
		
		if Input.is_action_just_pressed("LMB"):
			for position in editor.selected_tiles.keys():
				if tile_grid_pos == position:
					old_selected_tiles = editor.selected_tiles
					is_moving = true
					set_initial_buffer()
					move_tiles()
					tile_grid_starting_pos = position
					for positions in old_selected_tiles.keys():
						shared.set_tile(positions.x, positions.y, editor.layer, 0, 0, 0)
					return
				else:
					is_moving = false
					
			if editor.selected_tiles.empty():
				is_moving = false
				
			start_pos = mouse_pos
			highlight.rect_position = start_pos
			
		if is_moving == false:
			
			if Input.is_action_pressed("LMB"):
				selection_box.hide()
				box_expansion()
				highlight.show()
				
			if Input.is_action_just_released("LMB"):
				if highlight.rect_size > Vector2(1, 1):
					fill_rect.size = highlight.rect_size.snapped(TILE)/TILE_SIZE
					fill_rect.position = highlight.rect_position

					if start_pos.x < fill_rect.position.x*32:
						fill_rect.position.x = round(start_pos.x/TILE_SIZE)
					if start_pos.y < fill_rect.position.y*32:
						fill_rect.position.y = round(start_pos.y/TILE_SIZE)
					editor.selected_tiles = {}
					for y in range(fill_rect.position.y, fill_rect.position.y + fill_rect.size.y) if highlight.rect_scale.x == 1 else range(fill_rect.position.y - fill_rect.size.y, fill_rect.position.y):
						for x in range(fill_rect.position.x, fill_rect.position.x + fill_rect.size.x) if highlight.rect_scale.y == 1 else range(fill_rect.position.x - fill_rect.size.x, fill_rect.position.x):
							editor.selected_tiles[Vector2(x, y)] = shared.get_tile(x, y, editor.layer)
					highlight.hide()
					selection_box.show()
					item_actions.show_selection_actions()
				else:
					if !pasted:
						editor.selected_tiles = {}
						highlight.hide()
						selection_box.hide()
						item_actions.hide_selection_actions()
					else:
						highlight.hide()
						selection_box.show()
						pasted = false
				
		if is_moving == true:
			
			if Input.is_action_just_released("LMB"):
				is_moving = false
				selection_box.rect_position += (editor.selected_tiles.keys()[0] - old_selected_tiles.keys()[0])*32
				action(old_selected_tiles, editor.selected_tiles)
			
func action(old_tiles, new_tiles):
	var action := MoveTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.old_tiles = old_tiles
	action.new_tiles = new_tiles
	editor.action_manager.commit_action(action)
	editor.tile_buffer.clear()
	editor.selected_tiles = {}

func move_tiles():
	while is_moving:
		selection_box.hide()
		yield(get_tree(), "physics_frame")
		var relative_tile_grid_pos = tile_grid_pos - tile_grid_starting_pos
		var old_selected_tile_size = editor.selected_tiles.size()
		var new_selected_tiles = {}
		if relative_tile_grid_pos != Vector2(0, 0):
			editor.tile_buffer.clear()
			for tile_pos in editor.selected_tiles:
				var new_pos = tile_pos + relative_tile_grid_pos
				new_selected_tiles[new_pos] = editor.selected_tiles[tile_pos]
				editor.tile_buffer.set_cellv(new_pos, shared.tilemaps_node.get_tile(editor.selected_tiles[tile_pos][0], editor.selected_tiles[tile_pos][1], editor.selected_tiles[tile_pos][2]))
				editor.tile_buffer.update_bitmask_area(new_pos)
			if new_selected_tiles.size() == old_selected_tile_size:
				tile_grid_starting_pos = tile_grid_pos
				editor.selected_tiles = new_selected_tiles
				new_selected_tiles = {}
				
func set_initial_buffer():
	for tile_pos in editor.selected_tiles:
		editor.tile_buffer.set_cellv(tile_pos, shared.tilemaps_node.get_tile(editor.selected_tiles[tile_pos][0], editor.selected_tiles[tile_pos][1], editor.selected_tiles[tile_pos][2]))
		editor.tile_buffer.update_bitmask_area(tile_pos)

func box_expansion():
	highlight.rect_size.x = abs(start_pos.x - mouse_pos.x)
	highlight.rect_size.y = abs(start_pos.y - mouse_pos.y)
	
	if start_pos.x - mouse_pos.x > 0:
		highlight.rect_rotation = 180
		highlight.rect_scale.y = -1
		highlight.rect_scale.x = 1
	else:
		highlight.rect_rotation = 0
		highlight.rect_scale.y = 1
		highlight.rect_scale.x = 1
		
	if start_pos.y - mouse_pos.y > 0:
		highlight.rect_rotation = 180 if start_pos.x - mouse_pos.x < 0 else 0
		highlight.rect_scale.x = -1
	else:
		highlight.rect_rotation = 0 if start_pos.x - mouse_pos.x < 0 else 180
		highlight.rect_scale.x = 1
		
	selection_box.rect_scale = highlight.rect_scale
	selection_box.rect_size = highlight.rect_size
	selection_box.rect_rotation = highlight.rect_rotation
	selection_box.rect_global_position = highlight.rect_position



func _on_Paste_pressed():
	if editor.tool_manager.current_tool == self:
		var result = JSON.parse(OS.get_clipboard()).result
		var raw_tiles = result[0]
		var tiles: Dictionary
		for tile_pos in raw_tiles:
			tiles[get_tile_ver((value_util.decode_value(tile_pos) + camera.position))/32] = raw_tiles[tile_pos]
		if typeof(tiles) == TYPE_DICTIONARY:
			pasted = true
			editor.selected_tiles = tiles
			set_initial_buffer()
			selection_box.show()
			selection_box.rect_position = get_tile_ver(value_util.decode_value(result[1][0]) + camera.position)
			selection_box.rect_scale = value_util.decode_value(result[1][1])
			selection_box.rect_size = value_util.decode_value(result[1][2])
			selection_box.rect_rotation = result[1][3]


func _on_Copy_button_down():
	if editor.tool_manager.current_tool == self:
		var tiles: Dictionary
		for tile_pos in editor.selected_tiles:
			tiles[value_util.encode_value(tile_pos*32 - camera.position)] = editor.selected_tiles[tile_pos]
		OS.set_clipboard(JSON.print([tiles, [value_util.encode_value(Vector2(round(selection_box.rect_position.x - camera.position.x), round(selection_box.rect_position.y - camera.position.y))), value_util.encode_value(selection_box.rect_scale), value_util.encode_value(selection_box.rect_size), selection_box.rect_rotation]]))



func _on_Delete_button_down():
	if editor.tool_manager.current_tool == self:
		var action := PlaceTilesAction.new()
		action.shared = shared
		action.layer = editor.layer
		action.tileset_id = 0
		action.tile_id = 0
		action.palette = 0
		action.do_tiles = editor.selected_tiles.keys()
		editor.action_manager.commit_action(action)
		editor.selected_tiles = {}
