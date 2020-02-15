extends Resource

class_name LevelArea

var objects = []
var backgroundTiles: PoolStringArray
var foregroundTiles: PoolStringArray
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

func loadIn(node: Node):
	var character = node.get_node("../Character")
	var levelObjects = node.get_node("../LevelObjects")
	character.position = settings.spawn
	for object in objects:
		var nodeObject = loadObject(object)
		levelObjects.add_child(nodeObject)
