class_name TileSelection
extends EditorTool

const TILE_SIZE: int = 32
const TILE := Vector2(TILE_SIZE, TILE_SIZE)

export var animation_delay: float = 6
export var frame_count: int = 5

onready var highlight = $"%Highlight"
onready var selection_box = $"%SelectionBox"
onready var tools_manager = get_parent()

var mouse_pos: Vector2
var tile_grid_pos: Vector2

var tile_grid_starting_pos: Vector2
var old_selected_tiles: Dictionary = {}

var is_moving: bool = true

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
					move_tiles()
					tile_grid_starting_pos = position
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
				else:
					editor.selected_tiles = {}
					highlight.hide()
					selection_box.hide()
				
		if is_moving == true:
			
			if Input.is_action_just_released("LMB"):
				is_moving = false
				selection_box.rect_position += (editor.selected_tiles.keys()[0] - old_selected_tiles.keys()[0])*32
				var action := MoveTilesAction.new()
				action.shared = shared
				action.layer = editor.layer
				action.old_tile_locations = old_selected_tiles.keys()
				action.new_tiles = editor.selected_tiles
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
				print(relative_tile_grid_pos)
			if new_selected_tiles.size() == old_selected_tile_size:
				tile_grid_starting_pos = tile_grid_pos
				editor.selected_tiles = new_selected_tiles
				new_selected_tiles = {}

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
