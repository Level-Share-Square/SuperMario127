extends Resource

class_name LevelArea

var objects = []
var background_tiles := []
var foreground_tiles := []
var settings: LevelAreaSettings

func get_true_value(value):
	if typeof(value) == TYPE_DICTIONARY:
		# very hacky cause i dont know how else to add it
		if value.type == "Vector2":
			return Vector2(value.construction[0], value.construction[1])
	else:
		return value

func load_object(object: LevelObject):
	var object_class = load("res://src/objects/" + object.type + ".gd")
	var node = object_class.new()
	for key in object.properties:
		var value = object.properties[key]
		var true_value = get_true_value(value)
		node[key] = true_value
	return node

func load_editor_object(object: LevelObject):
	var object_class = load("res://src/editor_objects/" + object.type + ".gd")
	var node = object_class.new()
	for key in object.properties:
		var value = object.properties[key]
		var true_value = get_true_value(value)
		node[key] = true_value
	return node

func get_position_from_tile_index(index: int) -> Vector2:
	return Vector2(
		index - (floor(index / settings.size.x) * settings.size.x),
		floor(index / settings.size.x)
	)

func get_tile_index_from_position(position: Vector2) -> int:
	return int(floor((settings.size.x * position.y) + position.x))

func load_in(node: Node, isEditing: bool):
	var character = node.get_node("../Character")
	var level_objects = node.get_node("../LevelObjects")
	var tile_map = node.get_node("../TileMap")
	var global_vars = node.get_node("../GlobalVars")
	for index in range(foreground_tiles.size()):
		var tile = foreground_tiles[index]
		var position = get_position_from_tile_index(index)
		tile_map.set_cell(position.x, position.y, global_vars.get_tile(tile[0], tile[1]))
		tile_map.update_bitmask_area(Vector2(position.x, position.y))
	character.position = settings.spawn
	if !isEditing:
		for object in objects:
			var node_object = load_object(object)
			level_objects.add_child(node_object)
	else:
		for object in objects:
			var node_object = load_editor_object(object)
			level_objects.add_child(node_object)

func unload(node: Node):
	var level_objects = node.get_node("../LevelObjects")
	var tile_map = node.get_node("../TileMap")
	for object in level_objects.get_children():
		object.queue_free()
	for x in range(settings.size.x):
		for y in range(settings.size.y):
			tile_map.set_cell(x, y, -1)
