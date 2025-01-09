class_name LevelData


const DEFAULT_CODE_PATH: String = "res://level/default_level.tres"

const DEFAULT_NAME: String = "My Level"
const DEFAULT_AUTHOR: String = "Unknown"
const DEFAULT_DESCRIPTION: String = "This level has no description."
const DEFAULT_THUMBNAIL_URL: String = ""
 
const current_format_version := "0.5.2"

var name := DEFAULT_NAME
var author := DEFAULT_AUTHOR
var description := DEFAULT_DESCRIPTION
var thumbnail_url := DEFAULT_THUMBNAIL_URL

var areas = []
var functions = {}
var global_vars_node = null
var vars : LevelVars

var layout_ids: Array = []
var layout_palettes: Array = []
var pinned_items: Array = []


func _init(code: String = ""):
	if code == "":
		code = level_list_util.load_level_code_file(DEFAULT_CODE_PATH)
	load_in(code)
#	var ready_function_struct = FunctionStruct.new()
	
#	functions.size_ready_function = ready_function_struct
	
	####################
	
#	var process_function_struct = FunctionStruct.new()
	
#	var time_alive = InterpreterVar.new()
#	time_alive.path = ["object", "global", "time_alive"]
#
#	var should_scale_condition = LessThanCondition.new()
#	should_scale_condition.values = [time_alive, 10]
#
#	var if_scale = IfStatementInstruction.new()
#	if_scale.value = should_scale_condition
#	process_function_struct.instructions.append(if_scale)
#
#	var object_scale = InterpreterVar.new()
#	object_scale.path = ["object", "scale"]

#	var new_scale = AdditionOperation.new()
#	new_scale.values = [object_scale, Vector2(0.1, 0.1)]

#	var method_execution = MethodExecution.new()
#	method_execution.path = ["object", "set_property"]
#	method_execution.args = ["scale", new_scale, false]

#	var call_method = CallMethodInstruction.new()
#	call_method.scope = 0
#	call_method.value = method_execution
#	process_function_struct.instructions.append(call_method)
#
#	var exit_scope = ExitScopeInstruction.new()
#	exit_scope.scope = 1
#	process_function_struct.instructions.append(exit_scope)
#
#	var time_alive_addition = AdditionOperation.new()
#	time_alive_addition.values = [time_alive, 1]
#
#	var set_time_alive = SetValueInstruction.new()
#	set_time_alive.path = ["object", "global", "time_alive"]
#	set_time_alive.value = time_alive_addition
#	process_function_struct.instructions.append(set_time_alive)
	
#	functions.size_process_function = process_function_struct

func get_vector2(result) -> Vector2:
	return Vector2(result.x, result.y)

func get_area(result) -> LevelArea:
	var area = LevelArea.new()
	area.settings = get_settings(result.settings)
	area.tile_chunks.clear()
	area.very_foreground_tiles.clear()
	area.foreground_tiles.clear()
	area.background_tiles.clear()
	area.very_background_tiles.clear()

	area.tile_chunks = get_chunks([
		result.background_tiles, 
		result.foreground_tiles, 
		result.very_foreground_tiles, 
		result.very_background_tiles], 

		area.settings.bounds.size)

	# for very_foreground_tiles_result in result.very_foreground_tiles:
	# 	var tiles = get_tiles(very_foreground_tiles_result)
	# 	for tile in tiles:
	# 		area.very_foreground_tiles.append(tile)
	# for tiles_result in result.foreground_tiles:
	# 	var tiles = get_tiles(tiles_result)
	# 	for tile in tiles:
	# 		area.foreground_tiles.append(tile)
	# for background_tiles_result in result.background_tiles:
	# 	var tiles = get_tiles(background_tiles_result)
	# 	for tile in tiles:
	# 		area.background_tiles.append(tile)
	# for background_tiles_result in result.very_background_tiles:
	# 	var tiles = get_tiles(background_tiles_result)
	# 	for tile in tiles:
	# 		area.very_background_tiles.append(tile)

	for object_result in result.objects:
		var object = get_object(object_result)
		area.objects.append(object)
	return area
	
func get_settings(result) -> LevelAreaSettings:
	var settings = LevelAreaSettings.new()
	settings.sky = result.sky
	settings.background = result.background
	settings.background_palette = result.background_palette
	settings.music = result.music
	settings.gravity = abs(result.gravity)
	settings.timer = abs(result.timer)
	var size_vec2 = get_vector2(result.size)
	settings.bounds.size = Vector2(clamp(size_vec2.x, 24, 1500), clamp(size_vec2.y, 14, 1500))
	return settings
	
func get_chunks(resultLayers: Array, size: Vector2) -> Dictionary:
	var level_width := int(size.x)
	var chunks: Dictionary = {}
	var palette_string = "0"
	var tileset_id_string
	var tile_id_string
	var current_chunk = null
	var layer_index: int = 0
	for resultLayer in resultLayers:
		var tile_index: int = 0
		for result in resultLayer:
			#decode tile
			
			var result_split = result.split(":")
			if result_split.size() > 1:
				palette_string = result_split[0]
				result = result_split[1]
			
			tileset_id_string = "0x" + result[0] + result[1]
			tile_id_string = "0x" + result[2]
			var tile_repeat_string = ""
			if result.length() > 3:
				for index in range(4, result.length()):
					tile_repeat_string += result[index]
			else:
				tile_repeat_string += "1"
			var tileset_id = int(tileset_id_string)
			var palette_id = int(palette_string)
			var tile_repeat = int(tile_repeat_string)

			if(tileset_id==0): #air can we skipped since it won't get written to the chunks
				tile_index += tile_repeat
				continue
			
			#finish decoding
			var tile_id = int(tile_id_string)
			var tile = [tileset_id, tile_id, palette_id]
			palette_string = "0"


			var x: int = tile_index%level_width
			var y: int = tile_index/level_width

			current_chunk = get_chunk_for_position(x, y, layer_index, chunks)

			for _i in range(tile_repeat):
				if(x%16==0): #beginning of new chunk
					current_chunk = get_chunk_for_position(x, y, layer_index, chunks)

				current_chunk[x%16 + (y%16)*16] = tile
				tile_index+=1

				x = tile_index%level_width
				y = tile_index/level_width

		layer_index+=1
		
	return chunks

func get_chunk_for_position(x: int, y: int, layer: int, chunks: Dictionary) -> Array:
	var chunk_x: int = x / 16
	var chunk_y: int = y / 16
	var key := str(chunk_x,":",chunk_y,":",layer)
	if(chunks.has(key)):
		return chunks[key]
	else:
		var chunk := []
		chunk.resize(16*16)
		chunks[key] = chunk
		return chunk

func get_object(result) -> LevelObject:
	var object
	object = LevelObject.new()
	object.type_id = result.type_id
	object.palette = result.palette
	object.properties = result.properties
	return object

func load_in(code):
	vars = LevelVars.new()

	var result
	result = level_code_util.decode(code)

	if result.format_version == "0.4.0":
		result = conversion_util.convert_040_to_041(result)

	if result.format_version == "0.4.1":
		result.format_version = "0.4.2"

	if result.format_version == "0.4.2":
		result = conversion_util.convert_042_to_043(result)

	if result.format_version == "0.4.3":
		result.format_version = "0.4.4"
		
	if result.format_version == "0.4.4":
		result = conversion_util.convert_044_to_045(result)
	
	if result.format_version == "0.4.5":
		result.format_version = "0.4.6"

	if result.format_version == "0.4.6":
		result.format_version = "0.4.7"

	if result.format_version == "0.4.7":
		result = conversion_util.convert_047_to_048(result)
		
	if result.format_version == "0.4.8":
		result = conversion_util.convert_048_to_049(result)
	
	if result.format_version == "0.4.9":
		result = conversion_util.convert_049_to_050(result)

	if result.format_version == "0.5.0":
		result.format_version = "0.5.1"
	
	if result.format_version == "0.5.1":
		result = conversion_util.convert_051_to_052(result)

	assert(result.format_version)
	var format_version = result.format_version
	name = result.name
	author = result.author
	description = result.description
	thumbnail_url = result.thumbnail_url
	
	layout_ids = result.layout_ids
	layout_palettes = result.layout_palettes
	pinned_items = result.pinned_items
	
	if format_version == current_format_version:
		for area_result in result.areas:
			var area = get_area(area_result)
			areas.append(area)
	else:
		print("Outdated format version. Current version is " + current_format_version + ", but course uses version " + format_version + ".")

func get_encoded_level_data():
	
	var level_string = ""
	var level_name = name
	var level_author = author
	var level_description = description
	var level_thumbnail = thumbnail_url
	
	# resisting the urge to shoot myself
	# why cant u just automate this,,,
	level_string += current_format_version + ","
	level_string += level_name.percent_encode() + ","
	level_string += level_author.percent_encode() + ","
	level_string += level_description.percent_encode() + ","
	level_string += level_thumbnail.percent_encode() + ","
	
	level_string += "["
	for index in range(layout_ids.size()):
		if index != 0:
			level_string += ","
		level_string += str(layout_palettes[index]) + str(layout_ids[index])
	level_string += "^"
	for index in range(pinned_items.size()):
		if index != 0:
			level_string += ","
		level_string += str(pinned_items[index][1]) + str(pinned_items[index][0])
	level_string += "],"
	
	for area in areas:
		var settings = area.settings
		
		level_string += "["
		
		# Settings
		level_string += value_util.encode_value(settings.bounds.size) + ","
		
		level_string += value_util.encode_value(settings.sky) + ","
		level_string += value_util.encode_value(settings.background) + ","
		level_string += value_util.encode_value(settings.music) + ","
		level_string += value_util.encode_value(settings.gravity) + ","
		level_string += value_util.encode_value(settings.background_palette) + ","
		level_string += value_util.encode_value(settings.timer) + "~"
		
		var tiles := []
		var very_background_tiles := []
		var background_tiles := []
		var foreground_tiles := []

		
		level_code_util.generate_from_chunks(area.tile_chunks, [background_tiles, tiles, foreground_tiles, very_background_tiles], settings.bounds)
		# Tiles
		var saved_tiles = level_code_util.encode(tiles, settings)
		var saved_very_background_tiles = level_code_util.encode(very_background_tiles, settings)
		var saved_background_tiles = level_code_util.encode(background_tiles, settings)
		var saved_foreground_tiles = level_code_util.encode(foreground_tiles, settings)
		
		for tile in saved_tiles:
			level_string += tile + ","
		level_string.erase(level_string.length() - 1, 1)
		level_string += "~"

		for tile in saved_very_background_tiles:
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
			added_object += str(object.palette) + ","
			
			added_object += value_util.encode_value(value_util.get_true_value(object.properties[0]-settings.bounds.position*32)) + ","
			for i in range(1,object.properties.size()):
				added_object += value_util.encode_value(value_util.get_true_value(object.properties[i])) + ","
			added_object.erase(added_object.length() - 1, 1)
			level_string += added_object + "|"
		level_string.erase(level_string.length() - 1, 1)
		level_string += "],"
	level_string.erase(level_string.length() - 1, 1)
	return level_string

