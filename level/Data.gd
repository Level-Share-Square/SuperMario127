class_name LevelData

var current_format_version := "0.4.0"
var format_version := "0.4.0"
var name := "My Level"
var areas = []
var global_vars_node = null
	
func get_vector2(result) -> Vector2:
	return Vector2(result.x, result.y)

func get_area(result, is_json) -> LevelArea:
	var area = LevelArea.new()
	area.settings = get_settings(result.settings)
	for very_foreground_tiles_result in result.very_foreground_tiles:
		var tiles = get_tiles(very_foreground_tiles_result, is_json)
		for tile in tiles:
			area.very_foreground_tiles.append(tile)
	for tiles_result in result.foreground_tiles:
		var tiles = get_tiles(tiles_result, is_json)
		for tile in tiles:
			area.foreground_tiles.append(tile)
	for background_tiles_result in result.background_tiles:
		var tiles = get_tiles(background_tiles_result, is_json)
		for tile in tiles:
			area.background_tiles.append(tile)
	for object_result in result.objects:
		var object = get_object(object_result, is_json)
		area.objects.append(object)
	return area
	
func get_settings(result) -> LevelAreaSettings:
	var settings = LevelAreaSettings.new()
	settings.sky = result.sky
	settings.background = result.background
	settings.music = result.music
	settings.size = get_vector2(result.size)
	return settings
	
func get_tiles(result, is_json) -> Array:
	var tileset_id_string
	var tile_id_string
	if !is_json:
		tileset_id_string = "0x" + result[0] + result[1]
		tile_id_string = "0x" + result[2]
	else:
		tileset_id_string = "0x" + result[0] + result[1] + result[2]
		tile_id_string = "0x" + result[3]
	var tile_repeat_string = ""
	var add_amount = 1 if is_json else 0
	if result.length() > 3 + add_amount:
		for index in range(4 + add_amount, result.length()):
			tile_repeat_string += result[index]
	else:
		tile_repeat_string += "1"
	var tileset_id = tileset_id_string.hex_to_int()
	var tile_id = tile_id_string.hex_to_int()
	var tile_repeat = int(tile_repeat_string)
	var tile = [tileset_id, tile_id]
	var tiles = []
	for iterator in range(tile_repeat):
		tiles.append(tile)
	return tiles

func get_object(result, is_json) -> LevelObject:
	var object
	if !is_json:
		object = LevelObject.new()
		object.id = result.id
		object.name = result.name
		object.properties = result.properties
	else:
		object = LevelObject.new()
		object.name = result.type
		object.properties = result.properties
		object.id = 2
		if object.name == "Entrance": # i don't even care lol
			object.id = 1
		elif object.name == "Coin":
			object.id = 2
		elif object.name == "Shine":
			object.id = 3
		elif object.name == "MetalPlatform":
			object.id = 4
	return object

func load_in(code):
	var result
	result = rle_util.decode(code)

	assert(result.format_version)
	assert(result.name)
	format_version = result.format_version
	name = result.name
	
	if format_version == current_format_version:
		for area_result in result.areas:
			var area = get_area(area_result, is_json)
			areas.append(area)
	else:
		print("Outdated format version. Current version is " + current_format_version + ", but course uses version " + format_version + ".")
