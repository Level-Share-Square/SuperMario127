extends EditorTool

export var placeable_items: Resource

var level_bounds: Rect2
var tile_mode: bool = false


func _ready():
	level_bounds = Singleton.CurrentLevelData.level_data.areas[Singleton.CurrentLevelData.area].settings.bounds


func _update(delta: float):
	if editor.left_held or editor.right_held:
		if tile_mode:
			place_tile(placeable_items.placeable_items["bricks"])
		else:
			if Input.is_action_just_pressed("place"):
				place_object(placeable_items.placeable_items["coin"])


func place_tile(tile_item: PlaceableTile):
	var mouse_tile_position = editor.mouse_tile_position
	var last_mouse_tile_pos = editor.last_mouse_tile_pos
	
	if not level_bounds.has_point(editor.mouse_tile_position):
		return
	
	if last_mouse_tile_pos != mouse_tile_position or Input.is_action_just_pressed("place") or Input.is_action_just_pressed("erase"):
		if editor.left_held and not editor.right_held:
			shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, tile_item.tileset_id, tile_item.tile_id, tile_item.palette)
		elif editor.right_held and not editor.left_held:
			shared.set_tile(mouse_tile_position.x, mouse_tile_position.y, LevelShared.TileLayers.Middle, 0, 0, 0)


func place_object(object_item: PlaceableObject):
	var data = create_object_data(editor.mouse_position, object_item.object_id, object_item.palette)
	
	shared.create_object(data, true)


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
	
	
