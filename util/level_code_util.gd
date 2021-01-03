class_name level_code_util

static func is_valid(value : String):
	value = value.strip_edges(true, true)
	
	var re = RegEx.new()
	re.compile("^[0-9]")

	if not re.search_all(value): # Sorry for the endless if statements
		return false
	else:
		if (
			value.count(",", 0, value.length()) > 2 
			and value.count("[", 0, value.length()) > 0
			and value.count("]", 0, value.length()) > 0
			and value.split(",").size() > 2
		):
			return true
		else:
			return false

const empty_tile := [0,0,0]
static func encode(tiles, settings):
	#print(settings.bounds)
	var new_data = []
	var last_index = -1
	var last_palette = 0
	var count = 1
	var append_string = ""
	var prepend_string = ""
	
	for index in range(settings.bounds.size.x * settings.bounds.size.y):
		var encoded_tile = tiles[index]
		if not encoded_tile:
			encoded_tile = empty_tile

		var appended_tile = encoded_tile[0] * 10 + encoded_tile[1]
		
		if appended_tile != last_index or encoded_tile[2] != last_palette:
			if last_index != -1:
				prepend_string = "" if last_palette == 0 else str(last_palette) + ":"
				append_string = "" if count == 1 else ("*" + str(count))
				new_data.append(prepend_string + str(last_index).pad_zeros(3) + append_string)
			count = 1
			last_index = appended_tile
			last_palette = encoded_tile[2]
		else:
			count += 1

	prepend_string = ""
	append_string = "" if count == 1 else ("*" + str(count))
	new_data.append(str(last_index).pad_zeros(3) + append_string)
	#print(new_data)
	return new_data

static func generate_from_chunks(tile_chunks: Dictionary, layers: Array, bounds: Rect2):
	for layer in layers:
		layer.clear()
		layer.resize(bounds.size.x*bounds.size.y)

	for key in tile_chunks:
		var chunk : Array = tile_chunks[key]

		var _key : Array = key.split(":")
		var chunk_x := int(_key[0])
		var chunk_y := int(_key[1])
		var layer 	:= int(_key[2])

		for x in range(16):
			for y in range(16):
				var tile = chunk[x + y*16] #get tile from chunk
				if tile and bounds.has_point(Vector2(chunk_x*16 + x + 0.5, chunk_y*16 + y + 0.5)):
					#write tile in the tile array for this layer
					layers[layer][(chunk_x*16 + x-bounds.position.x) + (chunk_y*16 + y-bounds.position.y) * bounds.size.x] = tile
	
static func split_code_top_level(string):
	var parts = []
	var start_from = 0
	var bracket_level = 0
	for index in range(start_from, string.length()):
		var value = string[index]
		if value == ',' and bracket_level == 0 and string[index - 1] != "]":
			parts.append(string.substr(start_from, index - start_from))
			start_from = index + 1
		elif value == '[':
			bracket_level += 1
			if bracket_level == 1:
				start_from = index + 1
		elif value == ']':
			bracket_level -= 1
			if bracket_level == 0:
				parts.append(string.substr(start_from, index - start_from))
				start_from = index + 1
	return parts
		
static func decode(code: String):
	var result = {}

	code = code.strip_edges()
	var code_array = split_code_top_level(code)
	
	result.format_version = code_array[0]
	result.name = code_array[1].percent_decode()
	
	var add_amount = 1
	var func_array = []
	if result.format_version == "0.4.0" or result.format_version == "0.4.1":
		add_amount = 0
	else:
		func_array = split_code_top_level(code_array[2])
		
	for function in func_array:
		if function != "":
			print("B")
			
	var areas = code_array.size() - (2 + add_amount)
	
	result.areas = []
	
	
	for area_id in range(areas):
		var area_index = (2 + add_amount) + area_id
		
		var area_array = code_array[area_index].split("~")
	
		var area_settings_array = area_array[0].split(",")
		result.areas.append({})
		result.areas[area_id].settings = {}
		result.areas[area_id].settings.size = value_util.decode_value(area_settings_array[0])
		result.areas[area_id].settings.sky = value_util.decode_value(area_settings_array[1])
		result.areas[area_id].settings.background = value_util.decode_value(area_settings_array[2])
		result.areas[area_id].settings.music = value_util.decode_value(area_settings_array[3])
		if area_settings_array.size() > 4:
			result.areas[area_id].settings.gravity = value_util.decode_value(area_settings_array[4])
		else:
			result.areas[area_id].settings.gravity = 7.82
		
		
		if(conversion_util.compareVersions(result.format_version, "0.4.5") == -1):
			area_array.insert(2,"0*0")
		
		var area_tiles_array = area_array[1].split(",")
		result.areas[area_id].foreground_tiles = []
		for tile in area_tiles_array:
			result.areas[area_id].foreground_tiles.append(tile)
			
		var area_very_background_tiles_array = area_array[2].split(",")
		result.areas[area_id].very_background_tiles = []
		for tile in area_very_background_tiles_array:
			result.areas[area_id].very_background_tiles.append(tile)

		var area_background_tiles_array = area_array[3].split(",")
		result.areas[area_id].background_tiles = []
		for tile in area_background_tiles_array:
			result.areas[area_id].background_tiles.append(tile)
			
		var area_foreground_tiles_array = area_array[4].split(",")
		result.areas[area_id].very_foreground_tiles = []
		for tile in area_foreground_tiles_array:
			result.areas[area_id].very_foreground_tiles.append(tile)
			
		result.areas[area_id].objects = []
		if area_array.size() > 5:
			var objects_array = area_array[5].split("|")
			for object in objects_array:
				var object_array = object.split(",")
				var decoded_object = {}
				decoded_object.properties = []
				decoded_object.type_id = int(object_array[0])
				var index = 0
				for value in object_array:
					if index > 0:
						decoded_object.properties.append(value_util.decode_value(value))
					index += 1
				result.areas[area_id].objects.append(decoded_object)
	
	return result
