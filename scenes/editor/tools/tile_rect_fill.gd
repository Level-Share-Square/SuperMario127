class_name TileRectFill
extends EditorTool

const TILE_SIZE: int = 32
const TILE := Vector2(TILE_SIZE, TILE_SIZE)

onready var highlight = $"%Highlight"
onready var tools_manager = get_parent()

var mouse_pos: Vector2

var fill_rect: Rect2
var start_pos: Vector2

func _ready():
	hide()

func _physics_process(delta):
	mouse_pos = Vector2(int(get_global_mouse_position().x / 32) * 32, int(get_global_mouse_position().y / 32) * 32)
	if tools_manager.current_tool == self:
		if Input.is_action_just_pressed("LMB"):
			start_pos = mouse_pos
			highlight.rect_position = start_pos
		if Input.is_action_pressed("LMB"):
			box_expansion()
			show()
			
		if Input.is_action_just_released("LMB") && highlight.rect_size > Vector2(1, 1):
			fill_rect.size = highlight.rect_size.snapped(TILE)/TILE_SIZE
			fill_rect.position = highlight.rect_position

			if start_pos.x < fill_rect.position.x*32:
				fill_rect.position.x = round(start_pos.x/TILE_SIZE)
			if start_pos.y < fill_rect.position.y*32:
				fill_rect.position.y = round(start_pos.y/TILE_SIZE)
			
			for y in range(fill_rect.position.y, fill_rect.position.y + fill_rect.size.y) if highlight.rect_scale.x == 1 else range(fill_rect.position.y - fill_rect.size.y, fill_rect.position.y):
				for x in range(fill_rect.position.x, fill_rect.position.x + fill_rect.size.x) if highlight.rect_scale.y == 1 else range(fill_rect.position.x - fill_rect.size.x, fill_rect.position.x):
					var pos := Vector2(x, y)
					draw_tile(pos)
			finalize_placement()
			hide()

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

func draw_tile(pos: Vector2) -> void:
	var level_bounds: Rect2 = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds
	if not level_bounds.has_point(pos):
		return
	
	var item = editor.selected_item
	var cache_tile = shared.tilemaps_node.get_tile(item.tileset_id, item.tile_id, item.palette)
	
	if editor.tile_buffer.get_cell(pos.x, pos.y) == TileMap.INVALID_CELL:
		editor.tile_buffer.set_cellv(pos, cache_tile)
		editor.tile_buffer.update_bitmask_area(pos)

func finalize_placement() -> void:
	var action := PlaceTilesAction.new()
	action.shared = shared
	action.layer = editor.layer
	action.tileset_id = editor.selected_item.tileset_id
	action.tile_id = editor.selected_item.tile_id
	action.palette = editor.selected_item.palette
	action.do_tiles = editor.tile_buffer.get_used_cells()
	editor.action_manager.commit_action(action)
	
	editor.tile_buffer.clear()
