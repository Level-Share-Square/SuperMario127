extends Resource

class_name Level

var current_format_version := "0.3.0"
var format_version := "0.3.0"
var name := "My Level"
var areas = []

func get_vector2(result) -> Vector2:
	return Vector2(result.x, result.y)

func get_area(result) -> LevelArea:
	var area = LevelArea.new()
	area.settings = get_settings(result.settings)
	for tiles_result in result.foreground_tiles:
		var tiles = get_tiles(tiles_result)
		for tile in tiles:
			area.foreground_tiles.append(tile)
	for object_result in result.objects:
		var object = get_object(object_result)
		area.objects.append(object)
	return area
	
func get_settings(result) -> LevelAreaSettings:
	var settings = LevelAreaSettings.new()
	settings.background = result.background
	settings.music = result.music
	settings.size = get_vector2(result.size)
	settings.spawn = get_vector2(result.spawn)
	return settings
	
func get_tiles(result) -> Array:
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

func get_object(result) -> LevelObject:
	var object = LevelObject.new()
	object.type = result.type
	object.properties = result.properties
	return object

func load_in(json: LevelJSON):
	var parse = JSON.parse(json.contents)
	if parse.error != 0:
		print("Error " + parse.error_string + " at line " + parse.error_line)
		
	var result = parse.result
	assert(result.format_version)
	assert(result.name)
	format_version = result.format_version
	name = result.name
	if format_version == current_format_version:
		for area_result in result.areas:
			var area = get_area(area_result)
			areas.append(area)
	else:
		print("Outdated format version. Current version is " + current_format_version + ", but course uses version " + format_version + ".")

func unload(node: Node):
	var level_objects = node.get_node("../LevelObjects")
	for child in level_objects.get_children():
		child.queue_free()

func save_in(json: LevelJSON):
	pass
