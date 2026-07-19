class_name LevelCodeDeserializer
extends LevelCodeHandler


static func deserialize_level_code(code: String) -> LevelDataContainer:
	var level_code = LevelCodeTokenizer.splice_level(code)
	var metadata_code = LevelCodeTokenizer.splice_metadata(code)
	var level_components_code = LevelCodeTokenizer.splice_level_components(level_code)
	
	# all area codes (in one string)
	var area_list_code = level_components_code[0]
	var mission_data_code = level_components_code[1]
	var editor_data_code = level_components_code[2]
	
	# all area codes(in a string array)
	var areas_code = LevelCodeTokenizer.splice_areas(area_list_code)
	
	var new_level_metadata = deserialize_level_metadata_code(metadata_code)
	var new_current_area = deserialize_area_code(areas_code[0])
	var new_area_headers: Array = []
	for header in areas_code:
		new_area_headers.push_back(deserialize_area_header_code(header))
	
	var new_mission_data: Array = []
	var new_saved_editor_data = SavedEditorData.new()
	
	var level_data = LevelDataContainer.new(new_level_metadata,new_saved_editor_data, new_mission_data, new_area_headers)
	return level_data


static func deserialize_mission_data(mission_code) -> MissionData:
	return MissionData.new()


static func deserialize_area_code(area_code: String) -> AreaData:
	var area_components_code = LevelCodeTokenizer.splice_area_components(area_code)
	
	var layers_code = area_components_code[0]
	
	var area_header = deserialize_area_header_code(area_code)
	var layers = deserialize_layers_code(layers_code)
	
	return AreaData.new(area_header, layers)


static func deserialize_layers_code(layers_code: String) -> Array:
	var layers_code_array = LevelCodeTokenizer.splice_layers(layers_code)
	var layers = []
	for layer in layers_code_array:
		layers.push_back(deserialize_layer_code(layer))
	return layers


static func deserialize_layer_code(layer_code: String) -> LayerData:
	var layer_metadata_code = LevelCodeTokenizer.splice_metadata(layer_code)
	var layer_components = LevelCodeTokenizer.splice_layer_components(layer_code)
	var objects_code = layer_components[1]
	var tiles_code = layer_components[0]
	
	var layer_metadata: LayerMetadata = deserialize_layer_metadata_code(layer_metadata_code)
	var tile_data: TileData = deserialize_datas_code(tiles_code)[0]
	var objects: Array = deserialize_objects_code(objects_code)
	
	return LayerData.new(layer_metadata, tile_data, objects)


static func deserialize_tiles_code(tiles_code: String) -> Array:
	var tiles_code_array = LevelCodeTokenizer.splice_tiles(tiles_code)
	var tiles = []
	for tile in tiles_code_array:
		tiles.push_back(deserialize_tile_code(tile))
	
	return tiles


static func deserialize_tile_code(tile_code: String) -> Array:
	var data = deserialize_datas_code(tile_code)
	
	var tileset_id = data[0]
	var tile_type = data[1]
	var palette = data[2]
	var pos = data[3]
	
	return [tileset_id, tile_type, palette, pos]


static func deserialize_objects_code(objects_code: String) -> Array:
	var objects_code_array = LevelCodeTokenizer.splice_objects(objects_code)
	var objects = []
	for object in objects_code_array:
		objects.push_back(deserialize_object_code(object))
	
	return objects


static func deserialize_object_code(object_code: String) -> ObjectData:
	var object_metadata_code = LevelCodeTokenizer.splice_metadata(object_code)
	var object_var_code = LevelCodeTokenizer.splice_object(object_code)
	
	var object_metadata = deserialize_object_metadata_code(object_metadata_code)
	var object_vars = deserialize_object_properties(object_var_code)
	
	return ObjectData.new(object_metadata, object_vars)


static func deserialize_object_properties(code: String) -> Dictionary:
	var properties: Dictionary = {}
	
	var pair_codes: PoolStringArray = code.split(";", false)
	for pair_code in pair_codes:
		var pair: Array = LevelCodeTokenizer.splice_dictionary_entry(pair_code)
		var key: int = deserialize_data_code(pair[0])
		var value = deserialize_data_code(pair[1])

		properties.get_or_add(key, value)
	return properties
	


static func deserialize_level_metadata_code(level_metadata_code: String) -> LevelMetadata:
	var vars = deserialize_datas_code(level_metadata_code)
	
	var level_name = vars[0]
	var level_author = vars[1]
	var level_description = vars[2]
	var level_thumbnail_url = vars[3]
	var level_thumbnail_sky = vars[4]
	var level_thumbnail_background = vars[5]
	var level_thumbnail_background_palette = vars[6]
	
	return LevelMetadata.new(level_name, level_author, level_description, level_thumbnail_url, level_thumbnail_sky, level_thumbnail_background, level_thumbnail_background_palette)


# !! Takes full area code as input! so that the area code can be stored as a variable
static func deserialize_area_header_code(area_code: String) -> AreaHeader:
	var area_metadata_code = LevelCodeTokenizer.splice_metadata(area_code)
	var vars = deserialize_datas_code(area_metadata_code)
	
	var bounds: Rect2 = vars[0]
	var name: String = vars[1]
	var sky: int = vars[2]
	var background: int = vars[3]
	var background_palette: int = vars[4]
	var bg_autoscroll_speed: float = vars[5]
	var gravity: float = vars[6]
	var timer: float = vars[7]
	var music = vars[8]
	var underwater_music: String = vars[9]
	
	return AreaHeader.new(area_code, bounds, name, sky, background, background_palette, bg_autoscroll_speed, gravity, timer, music, underwater_music)


static func deserialize_layer_metadata_code(layer_metadata_code: String) -> LayerMetadata:
	var vars = deserialize_datas_code(layer_metadata_code)
	
	var parallax_distance: float = vars[0]
	var parallax_offset: Vector2 = vars[1]
	var autoset_tint: bool = vars[2]
	var layer_tint: Color = vars[3]
	var order: int = vars[4]
	var is_ground: bool = vars[5]
	var activated_mission_id: PoolIntArray = vars[6]
	
	return LayerMetadata.new(parallax_distance, parallax_offset, autoset_tint, layer_tint, order, is_ground, activated_mission_id)


static func deserialize_object_metadata_code(object_metadata_code: String) -> ObjectMetadata:
	var vars = deserialize_datas_code(object_metadata_code)
	
	var type_id: int = vars[0]
	var palette: int = vars[1]
	var position: Vector2 = vars[2]
	
	return ObjectMetadata.new(position, type_id, palette)


static func deserialize_dictionary(code: String) -> Dictionary:
	var pair_codes: Array = LevelCodeTokenizer.splice_dictionary(code)
	var dictionary: Dictionary = {}
	for pair_code in pair_codes:
		var pair: Array = LevelCodeTokenizer.splice_dictionary_entry(pair_code)
		var key: int = deserialize_data_code(pair[0])
		var value = deserialize_data_code(pair[1])
		
		dictionary.get_or_add(key, value)
	
	return dictionary


# basically, this is the finest grain part of the level code; we are just looking at primitive values
# pass in a list of primitive values to this function and it will interpret them
static func deserialize_datas_code(datas_code: String) -> Array:
	var vars_code = LevelCodeTokenizer.splice_data(datas_code)
	var vars = []
	for v in vars_code:
		vars.push_back(deserialize_data_code(v))
		
	return vars


static func base64_decode_int(number: String) -> int:
	number = number.strip_edges()
	number = number.strip_escapes()
	if number == "":
		return 0
	
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
	var is_negative = false
	if number[0] == "~":
		is_negative = true
		number = number.substr(1)
	
	var digits = []
	var index = 0
	for digit in number:
		var digit_int = characters.find(digit)
		digit_int = digit_int * pow(64, index)
		digits.append(digit_int)
		index += 1
		
	var final_number = 0
	for digit in digits:
		final_number += digit
	
	if is_negative:
		final_number = -final_number
	
	return final_number


static func base64_decode_float(number: String) -> float:
	var is_negative = false
	if number[0] == "~":
		is_negative = true
		number = number.substr(1)
	
	var components: PoolStringArray = number.split(".")
	var whole: int = 0
	var fract: int = 0
	if components.size() == 1:
		whole = base64_decode_int(components[0])
	else:
		whole = base64_decode_int(components[0])
		fract = base64_decode_int(components[1])
	
	var fract_string = "0." + str(fract)
	
	if not is_negative:
		return float(whole) + fract_string.to_float()
	else:
		return -float(whole) + fract_string.to_float()


static func deserialize_data_code(data_code: String):
	var type_code = data_code.substr(0, 1)
	var data = ""
	if type_code == "a":
		type_code = data_code.substr(0, 2)
		data = data_code.substr(2)
	else:
		data = data_code.substr(1)
	
	match type_code:
		LevelCodeHandler.TYPE_CODE_STRING:
#			return data
#			
			if data.empty():
				return ""
			else:
				data = data.replace("-", "+")
				data = data.replace("_", "/")
				# undo the padding replacement
				data = data.replace("~", "=")
				data = Marshalls.base64_to_raw(data)
				return data.decompress_dynamic(-1, File.COMPRESSION_DEFLATE).get_string_from_utf8()
		LevelCodeHandler.TYPE_CODE_INT:
			return base64_decode_int(data)
		LevelCodeHandler.TYPE_CODE_BOOL:
			return int(data) != 0
		LevelCodeHandler.TYPE_CODE_FLOAT:
			return base64_decode_float(data)
		LevelCodeHandler.TYPE_CODE_VECTOR2:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			return Vector2(data_array[0], data_array[1])
		LevelCodeHandler.TYPE_CODE_COLOR:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if(data_array.size() > 3):
				return Color(data_array[0], data_array[1], data_array[2], data_array[3])
			else:
				return Color(data_array[0], data_array[1], data_array[2], 255)
		LevelCodeHandler.TYPE_CODE_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			return deserialize_datas_code(data)
		LevelCodeHandler.TYPE_CODE_DICTIONARY:
			data = LevelCodeTokenizer.splice_data_array(data)
			return deserialize_dictionary(data)
		LevelCodeHandler.TYPE_CODE_STRING_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			return PoolStringArray(deserialize_datas_code(data))
		LevelCodeHandler.TYPE_CODE_INT_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			return PoolIntArray(deserialize_datas_code(data))
		LevelCodeHandler.TYPE_CODE_FLOAT_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			return PoolRealArray(deserialize_datas_code(data))
		LevelCodeHandler.TYPE_CODE_VECTOR2_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			return PoolVector2Array(deserialize_datas_code(data))
		LevelCodeHandler.TYPE_CODE_BYTES:
			if data.empty():
				return PoolByteArray()
			
			# convert from Base64URL to Base64
			data = data.replace("-", "+")
			data = data.replace("_", "/")
			# undo the padding replacement
			data = data.replace("~", "=")
			return Marshalls.base64_to_raw(data)
		LevelCodeHandler.TYPE_CODE_RECT2:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			return Rect2(data_array[0], data_array[1], data_array[2], data_array[3])
		LevelCodeHandler.TYPE_CODE_CURVE_2D:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			
			var point_data: PoolVector2Array = data_array
			
			var curve: Curve2D = Curve2D.new()
			for i in range(0, point_data.size(), 3):
				curve.add_point(point_data[i], point_data[i + 1], point_data[i + 2])
			
			return curve
		# TileData
		LevelCodeHandler.TYPE_CODE_TILE_DATA:
			data = LevelCodeTokenizer.splice_data_array(data)
			var tile_bytes = deserialize_datas_code(data)[0]
			
			var tile_data: TileData = TileData.new()
			var chunk_data: Dictionary = tile_util.tile_bytes_to_chunks(tile_bytes)
			for chunk_coords in chunk_data.keys():
				tile_data.set_chunk_data(chunk_coords, chunk_data.get(chunk_coords))
			
			return tile_data
		# Dialogue; not implemented yet
		LevelCodeHandler.TYPE_CODE_DIALOGUE_DATA:
			data = data
	
	printerr("Could not decode data string \"%s\"!")
	return null
