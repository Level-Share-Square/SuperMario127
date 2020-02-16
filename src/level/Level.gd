extends Resource

class_name Level

var formatVersion: String = "0.1.0"
var name: String = "My Level"
var areas = []

func getVector2(result) -> Vector2:
	return Vector2(result.x, result.y)

func getArea(result) -> LevelArea:
	var area = LevelArea.new()
	area.settings = getSettings(result.settings)
	for tilesResult in result.foregroundTiles:
		var tiles = getTiles(tilesResult)
		for tile in tiles:
			area.foregroundTiles.append(tile)
	for objectResult in result.objects:
		var object = getObject(objectResult)
		area.objects.append(object)
	return area
	
func getSettings(result) -> LevelAreaSettings:
	var settings = LevelAreaSettings.new()
	settings.background = result.background
	settings.music = result.music
	settings.size = getVector2(result.size)
	settings.spawn = getVector2(result.spawn)
	return settings
	
func getTiles(result) -> Array:
	var tileset_id_string = "0x" + result[0] + result[1]
	var tile_id_string = "0x" + result[2]
	var tile_repeat_string = "0x"
	for index in range(3, result.length()):
		tile_repeat_string += result[index]
	var tileset_id = tileset_id_string.hex_to_int()
	var tile_id = tile_id_string.hex_to_int()
	var tile_repeat = tile_repeat_string.hex_to_int()
	if tile_repeat == 0:
		tile_repeat = 1
	var tile = [tileset_id, tile_id]
	var tiles = []
	for iterator in range(tile_repeat):
		tiles.append(tile)
	return tiles

func getObject(result) -> LevelObject:
	var object = LevelObject.new()
	object.type = result.type
	object.properties = result.properties
	return object

func loadIn(json: LevelJSON):
	var parse = JSON.parse(json.contents)
	if parse.error != 0:
		print("Error " + parse.error_string + " at line " + parse.error_line)
		
	var result = parse.result
	assert(result.formatVersion)
	assert(result.name)
	formatVersion = result.formatVersion
	name = result.name
	if formatVersion == "0.2.0":
		for areaResult in result.areas:
			var area = getArea(areaResult)
			areas.append(area)
	else:
		print("Outdated format version. Current version is 0.1.0, but course uses version " + formatVersion + ".")

func unload(node: Node):
	var levelObjects = node.get_node("../LevelObjects")
	for child in levelObjects.get_children():
		child.queue_free()

func saveIn(json: LevelJSON):
	pass
