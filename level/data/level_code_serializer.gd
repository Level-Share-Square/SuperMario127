class_name LevelCodeSerializer
extends LevelCodeHandler


static func serialize_level_data(var level_data: LevelDataContainer) -> String:
	var code = "["

	code += serialize_level_metadata(level_data.level_metadata)
	code += serialize_areas(level_data.area_headers)
	code += serialize_editor_data(level_data.editor_data)

	code += "]"

	return code


static func serialize_editor_data(editor_data: EditorData) -> String:
	var code: String = ""
	
	code += serialize_data_array(editor_data.loadouts)
	code += serialize_data_array(editor_data.palettes)
	code += serialize_data_array(editor_data.fav_items)
	code += serialize_data_array(editor_data.fav_counts)
	
	return wrap_code_in_brackets(code)



static func serialize_collectible_data(collectible_data: CollectibleData) -> String:
	var code: String = ""
	
	code += serialize_missions(collectible_data.mission_data)
	code += serialize_star_coins(collectible_data.star_coin_data)
	
	return wrap_code_in_brackets(code)


static func serialize_missions(mission_data: Array) -> String:
	var code: String = ""
	
	for mission in mission_data:
		mission = mission as MissionData
		
		var mission_code: String = serialize_data_array(
			[
				mission.mission_uuid,
				mission.mission_show_in_menu,
				mission.shine_name,
				mission.shine_description,
				mission.shine_sort_order,
				mission.shine_color,
				mission.shine_force_leave,
				mission.spawn_area_id,
				mission.spawn_teleporter_tag,
			]
		)
		
		code += mission_code
	
	return wrap_code_in_brackets(code)


static func serialize_star_coins(star_coin_data: Array) -> String:
	var code: String = ""
	
	for star_coin in star_coin_data:
		star_coin = star_coin as StarCoinData
		
		var star_coin_code: String = serialize_data_array(
			[
				star_coin.star_coin_uuid,
				star_coin.star_coin_hint,
				star_coin.star_coin_color,
			]
		)
		
		code += star_coin_code
	
	return wrap_code_in_brackets(code)


static func serialize_areas(area_headers: Array) -> String:
	var areas_code: String = ""
	
	var area_data: AreaData
	for header in area_headers:
		header = header as AreaHeader
		
		area_data = LevelCodeDeserializer.deserialize_area_code(header.area_code)
		area_data.header = header
		# we do the enclosing in here because otherwise we can't
		# serialize_area to get the level codes for AreaHeader
		areas_code += wrap_code_in_brackets(serialize_area(area_data))
	
	return wrap_code_in_brackets(areas_code)


static func serialize_area(area: AreaData) -> String:
	var area_code: String = ""
	var header: AreaHeader = area.header

	area_code += serialize_metadata(
		[
			header.bounds, 
			header.name, 
			header.sky, 
			header.background, 
			header.background_palette, 
			header.bg_autoscroll_speed,
			header.gravity,
			header.timer,
			header.music,
			header.underwater_music
		]
	)
	
	area_code += serialize_layers(area.layers)
	
	return area_code


static func serialize_layers(layer_data: Array) -> String:
	var layers_code: String = "["
	
	for layer in layer_data:
		layers_code += serialize_layer(layer)
	
	layers_code += "]"
	
	return layers_code


static func serialize_layer(layer: LayerData) -> String:
	var layer_code: String = ""
	
	layer_code += serialize_metadata(
		[
			layer.layer_metadata.parallax_distance,
			layer.layer_metadata.parallax_offset,
			layer.layer_metadata.autoset_tint,
			layer.layer_metadata.layer_tint,
			layer.layer_metadata.order,
			layer.layer_metadata.is_ground,
			layer.layer_metadata.activated_mission_ids,
			layer.layer_metadata.layer_opacity,
			layer.layer_metadata.layer_name,
			layer.layer_metadata.is_origin,
		]
	)
	
	layer_code += serialize_layer_tile_data(layer.tile_data)
	layer_code += serialize_objects(layer.object_data)
	
	return wrap_code_in_brackets(layer_code)


static func serialize_objects(object_data: Array) -> String:
	var code: String = ""
	
	for object in object_data:
		var object_code: String = serialize_object(object)
		code += wrap_code_in_brackets(object_code)
	
	return wrap_code_in_brackets(code)


static func serialize_object(object: ObjectData) -> String:
		var object_code: String = ""
		
		object_code += serialize_metadata(
			[
				object.metadata.type_id,
				object.metadata.palette,
				object.metadata.position,
			]
		)
		
		var properties_code: String = ""
		for property_id in object.properties:
#			print("prop: ", property_id, " ", object.properties[property_id], " ", typeof(object.properties[property_id]))
			properties_code += serialize_data(property_id)
			properties_code += ":"
			properties_code += serialize_data(object.properties[property_id])
			properties_code += ";"
#			print("data: ", serialize_data(object.properties[property_id]))
		
		object_code += wrap_code_in_brackets(properties_code)
		
		return object_code


static func serialize_layer_tile_data(tile_data: TileData) -> String:
	return wrap_code_in_brackets(serialize_data(tile_data))


static func serialize_level_metadata(data: LevelMetadata) -> String:
	var metadata_code: String = "{"
	
	metadata_code += serialize_data_array(
		[
		data.level_name, 
		data.level_author, 
		data.level_description,
		data.level_thumbnail_url,
		data.level_thumbnail_sky,
		data.level_thumbnail_background,
		data.level_thumbnail_background_palette,
		# Since this is the only version of the serializer we're storing,
		# it's fine to just store this code version.
		ProjectSettings.get_setting("global/level_code_version"),
		]
	)
	metadata_code += serialize_collectible_data(data.collectible_data)
	
	metadata_code += "}"
	
	return metadata_code


static func serialize_metadata(values: Array) -> String:
	var metadata_code: String = "{"
	
	for value in values:
		metadata_code += serialize_data(value)
		metadata_code += ","
	
	metadata_code += "}"
	
	return metadata_code


static func serialize_data_array(values: Array) -> String:
	var data_array_code: String = ""
	
	for value in values:
		data_array_code += serialize_data(value)
		data_array_code += ","
	
	return wrap_code_in_brackets(data_array_code)


static func serialize_dictionary(dict: Dictionary) -> String:
	var code: String = ""
	
	for key in dict:
		var pair_code: String = ""
		pair_code += serialize_data(key)
		pair_code += ":"
		pair_code += serialize_data(dict[key])
		
		code += wrap_code_in_brackets(pair_code) + ","
	
	return wrap_code_in_brackets(code)


static func wrap_code_in_brackets(code: String) -> String:
	return "[%s]" % code


# Base64 integer encoding/decoding from Super Mario Shockwave (thanks luci :D)
static func base64_encode_int(number: int) -> String:
	var characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
	var is_negative = false
	if sign(number) < 0:
		is_negative = true
		number = abs(number)
	
	if number == 0:
		return characters[0]
	var digits = []
	while number:
		digits.append(int(number % 64))
		number = floor(number / 64)
	
	var string = ""
	if is_negative:
		string = "~"
	for digit in digits:
		string += characters[digit]
	return string


static func base64_encode_float(number: float) -> String:
	var is_negative = false
	if sign(number) < 0:
		is_negative = true
		number = abs(number)
	
	var number_components: PoolRealArray = str(number).split_floats(".")
	
	var string = ""
	if is_negative:
		string = "~"
	
	if number_components.size() == 1:
		string += base64_encode_int(number_components[0])
	else:
		string += base64_encode_int(number_components[0])
		string += "."
		string += base64_encode_int(number_components[1])
	
	return string


static func serialize_data(value) -> String:
	var data_code: String = ""
	
	match typeof(value):
		TYPE_STRING:
			value = value as String
#			data_code = LevelCodeHandler.TYPE_CODE_STRING + value
			data_code = LevelCodeHandler.TYPE_CODE_STRING
			
			if not value.empty():
				var bytes: PoolByteArray = value.to_utf8().compress(File.COMPRESSION_DEFLATE)
				data_code += Marshalls.raw_to_base64(bytes)
				# convert from Base64 to Base64URL
				data_code = data_code.replace("+", "-")
				data_code = data_code.replace("/", "_")
				# padding in Base64 isn't URI encoding safe, so we replace "="
				# with "~" while serializing
				data_code = data_code.replace("=", "~")
		TYPE_INT:
			value = value as int
			data_code = LevelCodeHandler.TYPE_CODE_INT + base64_encode_int(value)
		TYPE_BOOL:
			value = value as bool
			data_code = LevelCodeHandler.TYPE_CODE_BOOL + str(int(value))
		TYPE_REAL:
			value = value as float
			data_code = LevelCodeHandler.TYPE_CODE_FLOAT + base64_encode_float(value)
		TYPE_VECTOR2:
			value = value as Vector2
			data_code = LevelCodeHandler.TYPE_CODE_VECTOR2 + serialize_data_array([value.x, value.y])
		TYPE_COLOR:
			value = value as Color
			data_code = LevelCodeHandler.TYPE_CODE_COLOR + serialize_data_array([value.r, value.g, value.b, value.a])
		TYPE_ARRAY:
			value = value as Array
			data_code = LevelCodeHandler.TYPE_CODE_ARRAY + serialize_data_array(value)
		TYPE_DICTIONARY:
			value = value as Dictionary
			data_code = LevelCodeHandler.TYPE_CODE_DICTIONARY + serialize_dictionary(value)
		TYPE_STRING_ARRAY:
			value = value as PoolStringArray
			data_code = LevelCodeHandler.TYPE_CODE_STRING_ARRAY + serialize_data_array(value)
		TYPE_INT_ARRAY:
			value = value as PoolIntArray
			data_code = LevelCodeHandler.TYPE_CODE_INT_ARRAY + serialize_data_array(value)
		TYPE_REAL_ARRAY:
			value = value as PoolRealArray
			data_code = LevelCodeHandler.TYPE_CODE_FLOAT_ARRAY + serialize_data_array(value)
		TYPE_VECTOR2_ARRAY:
			value = value as PoolVector2Array
			data_code = LevelCodeHandler.TYPE_CODE_VECTOR2_ARRAY + serialize_data_array(value)
		TYPE_RAW_ARRAY:
			value = value as PoolByteArray
			data_code = LevelCodeHandler.TYPE_CODE_BYTES
			if not value.empty():
				data_code += Marshalls.raw_to_base64(value)
				# convert from Base64 to Base64URL
				data_code = data_code.replace("+", "-")
				data_code = data_code.replace("/", "_")
				# padding in Base64 isn't URI encoding safe, so we replace "="
				# with "~" while serializing
				data_code = data_code.replace("=", "~")
		TYPE_RECT2:
			value = value as Rect2
			data_code = LevelCodeHandler.TYPE_CODE_RECT2 + serialize_data_array([value.position.x, value.position.y, value.size.x, value.size.y])
		# Any type based on Object is encoded here
		TYPE_OBJECT:
			if value is Curve2D:
				value = value as Curve2D
				data_code = LevelCodeHandler.TYPE_CODE_CURVE_2D
				
				var point_data: PoolVector2Array = PoolVector2Array()
				for i in range(value.get_point_count()):
					point_data.append(value.get_point_position(i))
					point_data.append(value.get_point_in(i))
					point_data.append(value.get_point_out(i))
				
				data_code += serialize_data(point_data)
			elif value is TileData:
				value = value as TileData
				data_code = LevelCodeHandler.TYPE_CODE_TILE_DATA
				
				var tile_byte_data: PoolByteArray = tile_util.chunks_to_tile_bytes(value.chunks)
				data_code += serialize_data_array([tile_byte_data])
#			elif value is DialogueData:
#				pass
	
	return data_code
