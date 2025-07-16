extends EditorTool


var level_bounds: Rect2
var tile_mode: bool = false


func _ready():
	level_bounds = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds


func _update(delta: float):
	if editor.left_held or editor.right_held:
		if editor.selected_item is PlaceableTile:
			place_tile(editor.selected_item)
		else:
			place_object(editor.selected_item)


func place_tile(tile_item: PlaceableTile):
	var mouse_tile_position = (editor.mouse_position / editor.TILE_SIZE.x).floor()
	var last_mouse_tile_pos = (editor.last_mouse_pos / editor.TILE_SIZE.y).floor()
	
	if not level_bounds.has_point(mouse_tile_position):
		return
	
	if last_mouse_tile_pos != mouse_tile_position or Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
		var tiles: PoolVector2Array = line_util.get_line(mouse_tile_position, last_mouse_tile_pos)
		
		if editor.left_held and not editor.right_held:
			for pos in tiles:
				if level_bounds.has_point(pos):
					shared.set_tile(pos.x, pos.y, LevelShared.TileLayers.Middle, tile_item.tileset_id, tile_item.tile_id, tile_item.palette)
		elif editor.right_held and not editor.left_held:
			for pos in tiles:
				if level_bounds.has_point(pos):
					shared.set_tile(pos.x, pos.y, LevelShared.TileLayers.Middle, 0, 0, 0)


func place_object(object_item: PlaceableObject):
	if Input.is_action_just_pressed("place") and editor.hovered_objects.size() <= 0:
		var data = create_object_data(editor.mouse_position.snapped(Vector2(8, 8)), object_item.object_id, object_item.palette)
		shared.create_object(data, true)
	elif Input.is_action_pressed("erase"):
		for object in editor.hovered_objects.values():
			editor.hovered_objects.erase(object.name)
			shared.destroy_object(object, true)
			break


func create_object_data(position: Vector2, object_id: int, palette: int) -> ObjectData:
	var data = ObjectData.new()
	data.type_id = object_id
	data.palette = palette
	data.properties.append(position)
	data.properties.append(Vector2(1, 1))
	data.properties.append(0)
	data.properties.append(true)
	data.properties.append(true)
	data.properties.append(LevelShared.Layers.Middle)
	
	return data
