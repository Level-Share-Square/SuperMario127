class_name rle_util

static func encode(data):
	var new_data = []
	var last_index = ""
	var count = 1
	
	for index in data:
		if index != last_index:
			if last_index:
				var append_string = "*" + str(count)
				if count == 1:
					append_string = ""
				new_data.append(last_index + append_string)
			count = 1
			last_index = index
		else:
			count += 1
			
	var append_string_last = "*" + str(count)
	if count == 1:
		append_string_last = ""
	new_data.append(last_index + append_string_last)
	
	return new_data
	
static func decode_value(value: String):
	if value.ends_with("]"):
		value = value.rstrip("]")
		
	if value.begins_with("V2"):
		value = value.trim_prefix("V2")
		var array_value = value.split("x")
		return Vector2(array_value[0], array_value[1])
	elif value.begins_with("BL"):
		value = value.trim_prefix("BL")
		return true if value == "1" else false
	elif value.is_valid_integer():
		return int(value)
	elif value.is_valid_float():
		return float(value)
	else:
		return str(value).percent_decode()

static func decode(code: String):
	var result = {}
	var code_array = code.split("[")
	
	var level_settings_array = code_array[0].split(",")
	result.format_version = level_settings_array[0]
	result.name = level_settings_array[1].percent_decode()
	
	var area_array = code_array[1].split("~")
	area_array[0].erase(area_array[0].length() - 1, 1)
	
	var area_settings_array = area_array[0].split(",")
	result.areas = [{}]
	result.areas[0].settings = {}
	result.areas[0].settings.size = decode_value(area_settings_array[0])
	result.areas[0].settings.sky = decode_value(area_settings_array[1])
	result.areas[0].settings.background = decode_value(area_settings_array[2])
	result.areas[0].settings.music = decode_value(area_settings_array[3])
	
	var area_tiles_array = area_array[1].split(",")
	result.areas[0].foreground_tiles = []
	for tile in area_tiles_array:
		result.areas[0].foreground_tiles.append(tile)
		
	var area_background_tiles_array = area_array[2].split(",")
	result.areas[0].background_tiles = []
	for tile in area_background_tiles_array:
		result.areas[0].background_tiles.append(tile)
		
	var area_foreground_tiles_array = area_array[3].split(",")
	result.areas[0].very_foreground_tiles = []
	for tile in area_foreground_tiles_array:
		result.areas[0].very_foreground_tiles.append(tile)
		
	result.areas[0].objects = []
	if area_array.size() > 4:
		var objects_array = area_array[4].split("|")
		for object in objects_array:
			var object_array = object.split(",")
			var decoded_object = {}
			decoded_object.properties = []
			decoded_object.type_id = int(object_array[0])
			var index = 0
			for value in object_array:
				if index > 0:
					decoded_object.properties.append(decode_value(value))
				index += 1
			
			var size = decoded_object.properties.size()
			result.areas[0].objects.append(decoded_object)
	
	return result
