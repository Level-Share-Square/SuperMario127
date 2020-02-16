extends Resource

class_name LevelArea

var objects = []
var backgroundTiles := []
var foregroundTiles := []
var settings: LevelAreaSettings

func getTrueValue(value):
	if typeof(value) == TYPE_DICTIONARY:
		# very hacky cause i dont know how else to add it
		if value.type == "Vector2":
			return Vector2(value.construction[0], value.construction[1])
	else:
		return value

func loadObject(object: LevelObject):
	var objectClass = load("res://src/objects/" + object.type + ".gd")
	var node = objectClass.new()
	for key in object.properties:
		var value = object.properties[key]
		var trueValue = getTrueValue(value)
		node[key] = trueValue
	return node

func get_position_from_tile_index(index: int) -> Vector2:
	return Vector2(
		index - (floor(index / settings.size.x) * settings.size.x),
		floor(index / settings.size.x)
	)

func get_tile_index_from_position(position: Vector2) -> int:
	return int(floor((settings.size.x * position.y) + position.x))
	
func load_tile(tile: Array) -> int:
	if tile[0] == 0:
		return -1
	else:
		return 1

func loadIn(node: Node):
	var character = node.get_node("../Character")
	var level_objects = node.get_node("../LevelObjects")
	var tile_map = node.get_node("../TileMap")
	for index in range(foregroundTiles.size()):
		var tile = foregroundTiles[index]
		var position = get_position_from_tile_index(index)
		tile_map.set_cell(position.x, position.y, load_tile(tile))
	character.position = settings.spawn
	for object in objects:
		var nodeObject = loadObject(object)
		level_objects.add_child(nodeObject)
