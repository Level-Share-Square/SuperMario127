class_name LevelCodeDeserializer
extends Reference


const TYPE_CODE_STRING = "S" # String
const TYPE_CODE_INT = "I" # int
const TYPE_CODE_BOOL = "B" # bool
const TYPE_CODE_FLOAT = "F" # float
const TYPE_CODE_VECTOR2 = "V" # Vector2
const TYPE_CODE_COLOR = "C" # Color
const TYPE_CODE_ARRAY = "A" # Array
const TYPE_CODE_DICTIONARY = "K" # Dictionary
const TYPE_CODE_STRING_ARRAY = "aS" # PoolStringArray
const TYPE_CODE_INT_ARRAY = "aI" # PoolIntArray
const TYPE_CODE_FLOAT_ARRAY = "aF" # PoolRealArray; MAN I wish we had godot 4 for things like PackedFloat64Array
const TYPE_CODE_VECTOR2_ARRAY = "aV" # PoolVector2Array
const TYPE_CODE_BYTES = "Y" # PoolByteArray; (lacks the 'a' prefix due to not having a non-array equivalent)
const TYPE_CODE_RECT2 = "R" # Rect2
const TYPE_CODE_CURVE_2D = "U" # Curve2D
const TYPE_CODE_TILE_DATA = "T" # TileData (wrapper for a PoolByteArray)
const TYPE_CODE_DIALOGUE_DATA = "D" # DialogueData (wrapper for PoolStringArray)


static func deserialize_level_code(code: String):
	var level_code = LevelCodeTokenizer.splice_level(code)
	var metadata_code = LevelCodeTokenizer.splice_metadata(code)
	var level_components_code = LevelCodeTokenizer.splice_level_components(level_code)
	
	# all area codes (in one string)
	var area_list_code = level_components_code[0]
	var editor_data_code = level_components_code[1]
	var level_tags_code = level_components_code[2]
	
	# all area codes(in a string array)
	var areas_code = LevelCodeTokenizer.splice_areas(area_list_code)
	
	var new_level_metadata = deserialize_level_metadata_code(metadata_code)
	var new_current_area = deserialize_area_code(areas_code[0])
	var new_area_headers: Array = []
	for header in areas_code:
		new_area_headers.push_back(deserialize_area_header_code(header))
	
	var new_editor_data = deserialize_editor_data(editor_data_code)
	var new_level_tags = deserialize_level_tags(level_tags_code)
	
	var level_data = LevelDataContainer.new(new_level_metadata, new_editor_data, new_area_headers, new_level_tags)
	return level_data


static func deserialize_mission_data(mission_code) -> MissionData:
	return MissionData.new()


static func deserialize_editor_data(editor_data_code: String) -> EditorData:
	if editor_data_code.empty():
		return EditorData.new()
	
	var components: Array = LevelCodeTokenizer.splice_editor_data_components(editor_data_code)
	
	var layouts: Array = deserialize_datas_code(components[0])
	var palettes: Array = deserialize_datas_code(components[1])
	var fav_items: Array = deserialize_datas_code(components[2])
	var fav_count: Array = deserialize_datas_code(components[3])
	if components.size() <= 4: return EditorData.new(layouts, palettes, fav_items, fav_count)
	var selected_loadout: int = deserialize_datas_code(components[4])[0]
	var selected_layer: String = deserialize_datas_code(components[5])[0]
	var show_palettes: bool = deserialize_datas_code(components[6])[0]
	var area_bounds_increment: int = deserialize_datas_code(components[7])[0]
	
	return EditorData.new(layouts, palettes, fav_items, fav_count, selected_loadout, selected_layer, show_palettes, area_bounds_increment)

static func deserialize_level_tags(level_tags_code: String) -> LevelTags:
	if level_tags_code.empty():
		return LevelTags.new()
		
	var components: Array = LevelCodeTokenizer.splice_level_tags_components(level_tags_code)
	
	var teleport_tags: Array =  deserialize_datas_code(components[0])
	var dialogue_tags: Array =  deserialize_datas_code(components[1])
	var liquid_tags: Array =  deserialize_datas_code(components[2])
	
	return LevelTags.new(teleport_tags, dialogue_tags, liquid_tags)

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
	var tile_data: TileData
	var deserialized_tile_data = deserialize_datas_code(tiles_code)
	tile_data = TileData.new() if deserialized_tile_data == null else deserialized_tile_data[0]
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
	var object_data = ObjectData.new(object_metadata)
	var object_vars = deserialize_object_properties(object_var_code)
	for vars in object_vars:
		if object_vars[vars] == null:
			object_vars.erase(vars)
			object_data.mark_as_faulty("Invalid property in object")
	object_data.properties = object_vars
	return object_data


static func deserialize_object_properties(code: String) -> Dictionary:
	var properties: Dictionary = {}
	
	var pair_codes: PoolStringArray = code.split(";", false)
	for pair_code in pair_codes:
		var pair: Array = LevelCodeTokenizer.splice_dictionary_entry(pair_code)
		if(pair.size() < 2):
			properties.get_or_add("ERROR", null)
		else:
			var key: int = deserialize_data_code(pair[0])
			var value = deserialize_data_code(pair[1])

			properties.get_or_add(key, value)
	return properties
	


static func deserialize_level_metadata_code(level_metadata_code: String) -> LevelMetadata:
	var components = LevelCodeTokenizer.get_outermost_brackets(level_metadata_code)
	
	var metadata = LevelMetadata.new()
	var vars = deserialize_datas_code(components[0])
	if vars == null:
		metadata.mark_as_faulty("Invalid data in level metadata")
		return metadata
	metadata.level_name = set_or_use_default_value(vars, 0, metadata.level_name)
	metadata.level_author = set_or_use_default_value(vars, 1, metadata.level_author)
	metadata.level_description = set_or_use_default_value(vars, 2, metadata.level_description)
	metadata.level_thumbnail_url = set_or_use_default_value(vars, 3, metadata.level_thumbnail_url)
	metadata.level_thumbnail_sky = set_or_use_default_value(vars, 4, metadata.level_thumbnail_sky)
	metadata.level_thumbnail_background = set_or_use_default_value(vars, 5, metadata.level_thumbnail_background)
	metadata.level_thumbnail_background_palette = set_or_use_default_value(vars, 6, metadata.level_thumbnail_background_palette)
	metadata.level_version = set_or_use_default_value(vars, 7, metadata.level_version)

	metadata.collectible_data = deserialize_collectible_data_code(components[1])
	
	return metadata


static func deserialize_collectible_data_code(code: String) -> CollectibleData:
	var components: Array = LevelCodeTokenizer.get_outermost_brackets(code)

	var mission_data_code = components[0]
	var mission_data: Array = deserialize_mission_datas_code(mission_data_code)
	var star_coin_data_code = components[1]
	var star_coin_data: Array = deserialize_star_coin_datas_code(star_coin_data_code)
	var red_coin_count: int = deserialize_datas_code(components[2])[0]
	if components.size() == 3: return CollectibleData.new(mission_data, star_coin_data, red_coin_count)
	var used_mission_data_keys: Array = deserialize_datas_code(components[3])[0]
	var used_mission_data_values: Array = deserialize_datas_code(components[3])[1]
	var used_mission_data: Dictionary = {}
	for i in used_mission_data_keys.size():
		used_mission_data[used_mission_data_keys[i]] = used_mission_data_values[i]
	return CollectibleData.new(mission_data, star_coin_data, red_coin_count, used_mission_data)


static func deserialize_mission_datas_code(code: String) -> Array:
	var mission_codes = LevelCodeTokenizer.get_outermost_brackets(code)
	
	var mission_datas: Array = []
	for mission_code in mission_codes:
		var mission_data: MissionData = MissionData.new()
		var vars: Array = deserialize_datas_code(mission_code)
		
		mission_data.mission_uuid = set_or_use_default_value(vars, 0, mission_data.mission_uuid)
		mission_data.mission_show_in_menu = set_or_use_default_value(vars, 1, mission_data.mission_uuid)
		mission_data.shine_name = set_or_use_default_value(vars, 2, mission_data.shine_name)
		mission_data.shine_description = set_or_use_default_value(vars, 3, mission_data.shine_description)
		mission_data.shine_sort_order = set_or_use_default_value(vars, 4, mission_data.shine_sort_order)
		mission_data.shine_color = set_or_use_default_value(vars, 5, mission_data.shine_color)
		mission_data.shine_force_leave = set_or_use_default_value(vars, 6, mission_data.shine_force_leave)
		mission_data.spawn_area_id = set_or_use_default_value(vars, 7, mission_data.spawn_area_id)
		mission_data.spawn_teleporter_tag = set_or_use_default_value(vars, 8, mission_data.spawn_teleporter_tag)
		
		mission_datas.append(mission_data)
	
	return mission_datas


static func deserialize_star_coin_datas_code(code: String) -> Array:
	var star_coin_codes = LevelCodeTokenizer.get_outermost_brackets(code)

	var star_coin_datas: Array = []
	for star_coin_code in star_coin_codes:
		var star_coin_data: StarCoinData = StarCoinData.new()
		var vars: Array = deserialize_datas_code(star_coin_code)

		star_coin_data.star_coin_uuid = set_or_use_default_value(vars, 0, star_coin_data.star_coin_uuid)
		star_coin_data.star_coin_hint = set_or_use_default_value(vars, 1, star_coin_data.star_coin_hint)
		star_coin_data.star_coin_color = set_or_use_default_value(vars, 2, star_coin_data.star_coin_color)
		
		star_coin_datas.append(star_coin_data)
	
	return star_coin_datas


# !! Takes full area code as input! so that the area code can be stored as a variable
static func deserialize_area_header_code(area_code: String) -> AreaHeader:
	var area_metadata_code = LevelCodeTokenizer.splice_metadata(area_code)
	var vars = deserialize_datas_code(area_metadata_code)
	var area_header = AreaHeader.new()
	
	if vars == null:
		area_header.mark_as_faulty("Invalid data in area header")
		return area_header
	area_header.area_code = area_code
	area_header.bounds = set_or_use_default_value(vars, 0, area_header.bounds)
	area_header.name = set_or_use_default_value(vars, 1, area_header.name)
	area_header.sky = set_or_use_default_value(vars, 2, area_header.sky)
	area_header.background = set_or_use_default_value(vars, 3, area_header.background)
	area_header.background_palette = set_or_use_default_value(vars, 4, area_header.background_palette)
	area_header.bg_autoscroll_speed = set_or_use_default_value(vars, 5, area_header.bg_autoscroll_speed)
	area_header.gravity = set_or_use_default_value(vars, 6, area_header.gravity)
	area_header.timer = set_or_use_default_value(vars, 7, area_header.timer)
	area_header.music = set_or_use_default_value(vars, 8, area_header.music)
	area_header.underwater_music = set_or_use_default_value(vars, 9, area_header.underwater_music)
	area_header.shine_shard_count = set_or_use_default_value(vars, 10, area_header.shine_shard_count)
	area_header.max_purples_count = set_or_use_default_value(vars, 11, area_header.max_purples_count)

	return area_header


static func deserialize_layer_metadata_code(layer_metadata_code: String) -> LayerMetadata:
	var vars = deserialize_datas_code(layer_metadata_code)
	var layer_metadata = LayerMetadata.new()
	if vars == null:
		layer_metadata.mark_as_faulty("Invalid data in layer metadata")
		return layer_metadata
	
	layer_metadata.parallax_distance = set_or_use_default_value(vars, 0, layer_metadata.parallax_distance)
	layer_metadata.parallax_offset = set_or_use_default_value(vars, 1, layer_metadata.parallax_offset)
	layer_metadata.autoset_tint = set_or_use_default_value(vars, 2, layer_metadata.autoset_tint)
	layer_metadata.layer_tint = set_or_use_default_value(vars, 3, layer_metadata.layer_tint)
	layer_metadata.order = set_or_use_default_value(vars, 4, layer_metadata.order)
	layer_metadata.is_ground = set_or_use_default_value(vars, 5, layer_metadata.is_ground)
	layer_metadata.activated_mission_ids = set_or_use_default_value(vars, 6, layer_metadata.activated_mission_ids)
	layer_metadata.layer_opacity = set_or_use_default_value(vars, 7, layer_metadata.layer_opacity)
	layer_metadata.layer_name = set_or_use_default_value(vars, 8, layer_metadata.layer_name)
	layer_metadata.is_origin = set_or_use_default_value(vars, 9, layer_metadata.is_origin)
	layer_metadata.layer_uuid = set_or_use_default_value(vars, 10, layer_metadata.layer_uuid)
	layer_metadata.layer_visible = set_or_use_default_value(vars, 11, layer_metadata.layer_visible)
	
	return layer_metadata


static func deserialize_object_metadata_code(object_metadata_code: String) -> ObjectMetadata:
	var vars = deserialize_datas_code(object_metadata_code)
	var object_metadata = ObjectMetadata.new()
	if vars == null:
		object_metadata.mark_as_faulty("Invalid data in object metadata")
		return object_metadata
		
	object_metadata.type_id = vars[0]
	object_metadata.palette = vars[1]
	object_metadata.position = vars[2]
	
	return object_metadata


static func deserialize_dictionary(code: String) -> Dictionary:
	var pair_codes: Array = LevelCodeTokenizer.splice_dictionary(code)
	var dictionary: Dictionary = {}
	for pair_code in pair_codes:
		var pair: Array = LevelCodeTokenizer.splice_dictionary_entry(pair_code)
		if(pair.size() < 2):
			dictionary.get_or_add("ERROR", null)
		else:
			var key: int = deserialize_data_code(pair[0])
			var value = deserialize_data_code(pair[1])
			
			dictionary.get_or_add(key, value)
	
	return dictionary


# basically, this is the finest grain part of the level code; we are just looking at primitive values
# pass in a list of primitive values to this function and it will interpret them
static func deserialize_datas_code(datas_code: String):
	var vars_code = LevelCodeTokenizer.splice_data(datas_code)
	var vars = []
	for v in vars_code:
		vars.push_back(deserialize_data_code(v))
	if null in vars: return null
	return vars


static func base64_decode_int(number: String):
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
		if digit_int == -1: return null
		digit_int = digit_int * pow(64, index)
		digits.append(digit_int)
		index += 1
		
	var final_number: int = 0
	for digit in digits:
		final_number += digit
	
	if is_negative:
		final_number = -final_number
	
	
	return final_number


static func base64_decode_float(number: String):
	var is_negative = false
	if number[0] == "~":
		is_negative = true
		number = number.substr(1)
	
	var components: PoolStringArray = number.split(".")
	var whole: int = 0
	var fract: int = 0
	if components.size() == 1:
		whole = base64_decode_int(components[0])
		if whole == null: return null
	else:
		whole = base64_decode_int(components[0])
		fract = base64_decode_int(components[1])
		if whole == null or fract == null: return null
	
	var fract_string = "0." + str(fract)
	
	if not is_negative:
		return float(whole) + fract_string.to_float()
	else:
		return -float(whole) + fract_string.to_float()
		
static func set_or_use_default_value(vars: Array, index: int, default_value):
	if(index >= vars.size()):
		return default_value
	return vars[index]


static func deserialize_data_code(data_code: String):
	var type_code = data_code.substr(0, 1)
	var data = ""
	if type_code == "a":
		if data_code.length() < 3: return null
		type_code = data_code.substr(0, 2)
		data = data_code.substr(2)
	else:
		data = data_code.substr(1)
	
	match type_code:
		TYPE_CODE_STRING:
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
		TYPE_CODE_INT:
			return base64_decode_int(data)
		TYPE_CODE_BOOL:
			return int(data) != 0
		TYPE_CODE_FLOAT:
			return base64_decode_float(data)
		TYPE_CODE_VECTOR2:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			return Vector2(data_array[0], data_array[1])
		TYPE_CODE_COLOR:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if(data_array.size() > 3):
				return Color(data_array[0], data_array[1], data_array[2], data_array[3])
			else:
				return Color(data_array[0], data_array[1], data_array[2], 1)
		TYPE_CODE_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			return deserialize_datas_code(data)
		TYPE_CODE_DICTIONARY:
			data = LevelCodeTokenizer.splice_data_array(data)
			var dictionary = deserialize_dictionary(data)
			if null in dictionary.keys or null in dictionary.values: return null
			return dictionary
		TYPE_CODE_STRING_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if data_array == null: return null
			return PoolStringArray(data_array)
		TYPE_CODE_INT_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if data_array == null: return null
			return PoolIntArray(data_array)
		TYPE_CODE_FLOAT_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if data_array == null: return null
			return PoolRealArray(data_array)
		TYPE_CODE_VECTOR2_ARRAY:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if data_array == null: return null
			return PoolVector2Array(data_array)
		TYPE_CODE_BYTES:
			if data.empty():
				return PoolByteArray()
			
			# convert from Base64URL to Base64
			data = data.replace("-", "+")
			data = data.replace("_", "/")
			# undo the padding replacement
			data = data.replace("~", "=")
			return Marshalls.base64_to_raw(data)
		TYPE_CODE_RECT2:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if data_array == null: return null
			return Rect2(data_array[0], data_array[1], data_array[2], data_array[3])
		TYPE_CODE_CURVE_2D:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if data_array == null: return null
			var point_data: PoolVector2Array = data_array
			
			var curve: Curve2D = Curve2D.new()
			for i in range(0, point_data.size(), 3):
				curve.add_point(point_data[i], point_data[i + 1], point_data[i + 2])
			
			return curve
		# TileData
		TYPE_CODE_TILE_DATA:
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if data_array == null: return null
			var tile_bytes = data_array[0]
			
			var tile_data: TileData = TileData.new()
			var chunk_data: Dictionary = tile_util.tile_bytes_to_chunks(tile_bytes)
			for chunk_coords in chunk_data.keys():
				tile_data.set_chunk_data(chunk_coords, chunk_data.get(chunk_coords))
			
			return tile_data
		# Dialogue; not implemented yet
		TYPE_CODE_DIALOGUE_DATA:
			data = data
	
	printerr("Could not decode data string \"%s\"!")
	return null
