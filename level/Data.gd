class_name LevelData

var current_format_version := "0.4.1"
var format_version := "0.4.1"
var name := "My Level"
var areas = []
var global_vars_node = null
	
func get_vector2(result) -> Vector2:
	return Vector2(result.x, result.y)

func get_area(result) -> LevelArea:
	var area = LevelArea.new()
	area.settings = get_settings(result.settings)
	for very_foreground_tiles_result in result.very_foreground_tiles:
		var tiles = get_tiles(very_foreground_tiles_result)
		for tile in tiles:
			area.very_foreground_tiles.append(tile)
	for tiles_result in result.foreground_tiles:
		var tiles = get_tiles(tiles_result)
		for tile in tiles:
			area.foreground_tiles.append(tile)
	for background_tiles_result in result.background_tiles:
		var tiles = get_tiles(background_tiles_result)
		for tile in tiles:
			area.background_tiles.append(tile)
	for object_result in result.objects:
		var object = get_object(object_result)
		area.objects.append(object)
	return area
	
func get_settings(result) -> LevelAreaSettings:
	var settings = LevelAreaSettings.new()
	settings.sky = result.sky
	settings.background = result.background
	settings.music = result.music
	settings.size = get_vector2(result.size)
	return settings
	
func get_tiles(result) -> Array:
	var tileset_id_string
	var tile_id_string
	tileset_id_string = "0x" + result[0] + result[1]
	tile_id_string = "0x" + result[2]
	var tile_repeat_string = ""
	if result.length() > 3:
		for index in range(4, result.length()):
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

func get_object(result) -> LevelObject:
	var object
	object = LevelObject.new()
	object.type_id = result.type_id
	object.properties = result.properties
	return object

func load_in(code):
	var result
	var is_json = false
	if code[0] == "{":
		result = JSON.parse(code).result
		is_json = true
	else:
		result = rle_util.decode(code)

	if result.format_version == "0.3.3":
		result = conversion_util.convert_033_to_040(result)
	if result.format_version == "0.4.0":
		result.format_version = "0.4.1"

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

func get_encoded_level_data():
	
	var level_string = ""
	var format_version = "0.4.1"
	var level_name = name
	
	
	level_string += format_version + ","
	level_string += level_name.percent_encode() + ","
	
	for area in areas:
		var saved_tiles = []
		var saved_background_tiles = []
		var saved_foreground_tiles = []
		
		var settings = area.settings
		
		level_string += "["
		
		# Settings
		var level_size = settings.size
		level_string += value_util.encode_value(settings.size) + ","
		level_string += value_util.encode_value(settings.sky) + ","
		level_string += value_util.encode_value(settings.background) + ","
		level_string += value_util.encode_value(settings.music) + "~"
		
		# Tiles
		for index in range(settings.size.x * settings.size.y):
			var encoded_tile = area.foreground_tiles[index]
			var appended_tile = str(encoded_tile[0]).pad_zeros(2) + str(encoded_tile[1])
			saved_tiles.append(appended_tile)	
			
		for index in range(settings.size.x * settings.size.y):
			var encoded_tile_background = area.background_tiles[index]
			var appended_tile_background = str(encoded_tile_background[0]).pad_zeros(2) + str(encoded_tile_background[1])
			saved_background_tiles.append(appended_tile_background)	
	
		for index in range(settings.size.x * settings.size.y):
			var encoded_tile_very_foreground = area.very_foreground_tiles[index]
			var appended_tile_very_foreground = str(encoded_tile_very_foreground[0]).pad_zeros(2) + str(encoded_tile_very_foreground[1])
			saved_foreground_tiles.append(appended_tile_very_foreground)	
		saved_tiles = rle_util.encode(saved_tiles)
		saved_background_tiles = rle_util.encode(saved_background_tiles)
		saved_foreground_tiles = rle_util.encode(saved_foreground_tiles)
		
		for tile in saved_tiles:
			level_string += tile + ","
		level_string.erase(level_string.length() - 1, 1)
		level_string += "~"
		
		for tile in saved_background_tiles:
			level_string += tile + ","
		level_string.erase(level_string.length() - 1, 1)
		level_string += "~"
		
		for tile in saved_foreground_tiles:
			level_string += tile + ","
		level_string.erase(level_string.length() - 1, 1)
		level_string += "~"
		
		for object in area.objects:
			var added_object = ""
			added_object += str(object.type_id) + ","
			for value in object.properties:
				added_object += value_util.encode_value(value_util.get_true_value(value)) + ","
			added_object.erase(added_object.length() - 1, 1)
			level_string += added_object + "|"
		level_string.erase(level_string.length() - 1, 1)
		level_string += "],"
	level_string.erase(level_string.length() - 1, 1)
	return level_string
