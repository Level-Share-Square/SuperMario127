extends EditorTool


var level_bounds: Rect2


func _ready():
	level_bounds = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds


func _update(delta: float):
#	print("left: ", editor.left_held)
#	print("right: ", editor.right_held)
	
	if editor.left_held or editor.right_held:
		place_tile()


func place_tile():
	var mouse_tile_position = editor.mouse_tile_position
	var last_mouse_tile_pos = editor.last_mouse_tile_pos
	
	if not level_bounds.has_point(editor.mouse_tile_position):
		return
	
	if last_mouse_tile_pos != mouse_tile_position or Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
		if editor.left_held and not editor.right_held:
			shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, 1, 0, 0)
		elif editor.right_held and not editor.left_held:
			shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, 0, 0, 0)
