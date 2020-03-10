class_name LevelArea

var objects = []
var background_tiles := []
var foreground_tiles := []
var very_foreground_tiles := []
var settings: LevelAreaSettings

func get_true_value(value):
	if typeof(value) == TYPE_DICTIONARY:
		# very hacky cause i dont know how else to add it
		if value.type == "Vector2":
			return Vector2(value.construction[0], value.construction[1])
	else:
		return value
		
func get_value_from_true(value):
	# again very hacky cause i dont know how else to add it
	if typeof(value) == TYPE_VECTOR2:
		return {type="Vector2", construction=[value.x, value.y]}
	else:
		return value
		
func encode_value(value):
	# again very hacky cause i dont know how else to add it
	if typeof(value) == TYPE_VECTOR2:
		return "V2" + str(stepify(value.x,0.01)) + "x" + str(stepify(value.y, 0.01))
	else:
		return str(value)

# This method should be moved to the level class
func get_encoded_level_data():
	
	var level_string = ""
	var level_size = settings.size
	var format_version = "0.4.0"
	var level_name = "My Level"
	
	var saved_tiles = []
	var saved_background_tiles = []
	var saved_foreground_tiles = []
	
	level_string += format_version + ","
	level_string += level_name.percent_encode() + ","
	
	level_string += "["
	
	# Settings
	level_string += encode_value(settings.size) + ","
	level_string += encode_value(settings.sky) + ","
	level_string += encode_value(settings.background) + ","
	level_string += encode_value(settings.music) + "~"
	
	# Tiles
	for index in range(settings.size.x * settings.size.y):
		var encoded_tile = foreground_tiles[index]
		var appended_tile = encoded_tile[0] + encoded_tile[1]
		saved_tiles.append(appended_tile)	
		
	for index in range(settings.size.x * settings.size.y):
		var encoded_tile_background = background_tiles[index]
		var appended_tile_background = encoded_tile_background[0] + encoded_tile_background[1]
		saved_background_tiles.append(appended_tile_background)	

	for index in range(settings.size.x * settings.size.y):
		var encoded_tile_very_foreground = foreground_tiles[index]
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
	
	for index in objects:
		var added_object = ""
		added_object += index.id + ","
		for property in index.properties:
			added_object += encode_value(get_true_value(index.properties[property])) + ","
		added_object.erase(added_object.length() - 1, 1)
		level_string += added_object + "|"
	level_string.erase(level_string.length() - 1, 1)
	level_string += "]"
	return level_string
