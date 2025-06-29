extends EditorTool


var level_bounds: Rect2

var mouse_position := Vector2.ZERO
var mouse_tile_position := Vector2.ZERO

var last_mouse_pos := Vector2.ZERO
var last_mouse_tile_pos := Vector2.ZERO


func _ready():
	level_bounds = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds


func _update(delta: float):
	mouse_position = get_global_mouse_position()
	mouse_tile_position = (mouse_position / 32).floor()
	
	place_tile()
	
	last_mouse_pos = mouse_position
	last_mouse_tile_pos = mouse_tile_position


func place_tile():
	if not level_bounds.has_point(mouse_tile_position):
		return
	
	
	if Input.is_action_just_pressed("place"):
		shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, 1, 0, 0)
		return
	elif Input.is_action_just_pressed("erase"):
		shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, 0, 0, 0)
		return
	
	if last_mouse_tile_pos == mouse_tile_position:
		return
	
	if Input.is_action_pressed("place"):
		shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, 1, 0, 0)
	elif Input.is_action_pressed("erase"):
		shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, 0, 0, 0)
