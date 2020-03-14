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
		object.type_id = result.type_id
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
	var is_json = false
	if code[0] == "{":
		result = JSON.decode(code)
		is_json = true
	else:
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

func get_encoded_level_data():
	
	var level_string = ""
	var format_version = "0.4.0"
	var level_name = "My Level"
	
	
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
			var appended_tile = encoded_tile[0] + encoded_tile[1]
			saved_tiles.append(appended_tile)	
			
		for index in range(settings.size.x * settings.size.y):
			var encoded_tile_background = area.background_tiles[index]
			var appended_tile_background = encoded_tile_background[0] + encoded_tile_background[1]
			saved_background_tiles.append(appended_tile_background)	
	
		for index in range(settings.size.x * settings.size.y):
			var encoded_tile_very_foreground = area.very_foreground_tiles[index]
			var appended_tile_very_foreground = encoded_tile_very_foreground[0] + encoded_tile_very_foreground[1]
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
		
		for index in area.objects:
			var added_object = ""
			added_object += index.id + ","
			for property in index.properties:
				added_object += value_util.encode_value(value_util.get_true_value(index.properties[property])) + ","
			added_object.erase(added_object.length() - 1, 1)
			level_string += added_object + "|"
		level_string.erase(level_string.length() - 1, 1)
		level_string += "],"
	level_string.erase(level_string.length() - 1, 1)
	return level_string
