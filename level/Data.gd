class_name LevelDataOld
extends Resource


const DEFAULT_CODE_PATH: String = "res://level/default_level.tres"

const DEFAULT_NAME: String = "My Level"
const DEFAULT_AUTHOR: String = "Unknown"
const DEFAULT_DESCRIPTION: String = "This level has no description."
const DEFAULT_THUMBNAIL_URL: String = ""
 
const current_format_version := "0.5.5"

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

var loadouts: Array = []
var favorites: Array = []
var palettes: Array = []
var fav_items: Array = []

static func check_code(code):
	return typeof(code) == TYPE_DICTIONARY or code.size() >= 5


func _init(code: String = "",skip: bool = false):
	if (skip):
		return
	if code == "":
		code = level_list_util.load_level_code_file(DEFAULT_CODE_PATH)


func get_vector2(result) -> Vector2:
	if (typeof(result) != TYPE_VECTOR2):
		return Vector2(24,14)
	return Vector2(result.x, result.y)


func get_area(result) -> LevelAreaOld:
	var area = LevelAreaOld.new()
	area.tile_chunks.clear()
	area.very_foreground_tiles.clear()
	area.foreground_tiles.clear()
	area.background_tiles.clear()
	area.very_background_tiles.clear()
	
	area.sky = result.sky
	area.background = result.background
	area.background_palette = result.background_palette
	
	area.gravity = abs(result.gravity)
	area.timer = abs(result.timer)
	area.name = result.name
	
	area.music = result.music
	area.underwater_music = result.underwater_music
	
	area.tile_chunks = get_chunks([
		result.background_tiles, 
		result.foreground_tiles, 
		result.very_foreground_tiles, 
		result.very_background_tiles], 

		area.bounds.size)

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


#func get_settings(result) -> LevelAreaOldSettings:
#	var settings = LevelAreaOldSettings.new()
#	settings.sky = result.sky
#	settings.background = result.background
#	settings.background_palette = result.background_palette
#	settings.music = result.music
#	settings.gravity = abs(result.gravity)
#	settings.timer = abs(result.timer)
#	settings.name = result.name
#	settings.underwater_music = result.underwater_music
#	var size_vec2 = get_vector2(result.size)
#	settings.bounds.size = Vector2(clamp(size_vec2.x, 24, 1500), clamp(size_vec2.y, 14, 1500))
#	return settings


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


func get_object(result) -> ObjectData:
	var object
	object = ObjectData.new()
	object.type_id = result.type_id
	object.palette = result.palette
	object.properties = result.properties
	return object


#func load_in(code):
#	print("loading in level data...")
#	vars = LevelVars.new()
#
#	var result
#	result = level_code_util.decode(code)
#
#	if !check_code(result):
#		return
#
#	if result.format_version == "0.4.0":
#		result = conversion_util.convert_040_to_041(result)
#
#	if result.format_version == "0.4.1":
#		result.format_version = "0.4.2"
#
#	if result.format_version == "0.4.2":
#		result = conversion_util.convert_042_to_043(result)
#
#	if result.format_version == "0.4.3":
#		result.format_version = "0.4.4"
#
#	if result.format_version == "0.4.4":
#		result = conversion_util.convert_044_to_045(result)
#
#	if result.format_version == "0.4.5":
#		result.format_version = "0.4.6"
#
#	if result.format_version == "0.4.6":
#		result.format_version = "0.4.7"
#
#	if result.format_version == "0.4.7":
#		result = conversion_util.convert_047_to_048(result)
#
#	if result.format_version == "0.4.8":
#		result = conversion_util.convert_048_to_049(result)
#
#	if result.format_version == "0.4.9":
#		result = conversion_util.convert_049_to_050(result)
#
#	if result.format_version == "0.5.0":
#		result.format_version = "0.5.1"
#
#	if result.format_version == "0.5.1":
#		result = conversion_util.convert_051_to_052(result)
#
#	if result.format_version == "0.5.2":
#		result = conversion_util.convert_052_to_053(result)
#
#	assert(result.format_version)
#	var version_int = result.format_version.replace(".","")
#	var format_version = result.format_version
#	name = result.name
#
#	if (version_int.is_valid_integer()):
#		author = result.author
#		description = result.description
#		thumbnail_url = result.thumbnail_url
#
#	layout_ids = result.layout_ids
#	layout_palettes = result.layout_palettes
#	pinned_items = result.pinned_items
#
#	if format_version == current_format_version:
#		for area_result in result.areas:
#			if (area_result.size() == 6):
#				var area = get_area(area_result)
#				areas.append(area)
#	else:
#		print("Outdated format version. Current version is " + current_format_version + ", but course uses version " + format_version + ".")


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
	var loadout_index = 0
	for loadout in loadouts:
		level_string += "%s^" % [str(favorites[loadout_index])]
		var item_index = 0
		for item in loadout:
			level_string += str(palettes[loadout_index][item_index])
			level_string += "%s," % [item] if item_index != loadout.size() - 1 else "%s" % [item]
			item_index += 1
		if loadout_index != loadouts.size() - 1:
			level_string += "|"
		loadout_index += 1
	level_string += "],"
	
	for area in areas:
		level_string += "["
		
		# Settings
		level_string += value_util.encode_value(area.bounds.size) + ","
		
		level_string += value_util.encode_value(area.sky) + ","
		level_string += value_util.encode_value(area.background) + ","
		level_string += value_util.encode_value(area.music) + ","
		level_string += value_util.encode_value(area.gravity) + ","
		level_string += value_util.encode_value(area.background_palette) + ","
		level_string += value_util.encode_value(area.timer) + ","
		level_string += value_util.encode_value(area.name) + ","
		level_string += value_util.encode_value(area.underwater_music) + "~"
		
		var tiles := []
		var very_background_tiles := []
		var background_tiles := []
		var foreground_tiles := []

		
		level_code_util.generate_from_chunks(area.tile_chunks, [background_tiles, tiles, foreground_tiles, very_background_tiles], area.bounds)
		# Tiles
		var saved_tiles = level_code_util.encode(tiles, area.bounds.size)
		var saved_very_background_tiles = level_code_util.encode(very_background_tiles, area.bounds.size)
		var saved_background_tiles = level_code_util.encode(background_tiles, area.bounds.size)
		var saved_foreground_tiles = level_code_util.encode(foreground_tiles, area.bounds.size)
		
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
			
			added_object += value_util.encode_value(value_util.get_true_value(object.properties[0]-area.bounds.position*32)) + ","
			for i in range(1,object.properties.size()):
				added_object += value_util.encode_value(value_util.get_true_value(object.properties[i])) + ","
			added_object.erase(added_object.length() - 1, 1)
			level_string += added_object + "|"
		level_string.erase(level_string.length() - 1, 1)
		level_string += "],"
	level_string.erase(level_string.length() - 1, 1)
	return level_string

func get_encoded_area_data(area: LevelAreaOld):
	var level_string: String
	
	level_string += "LevelAreaOld_"
	
	# Settings
	level_string += value_util.encode_value(area.bounds.size) + ","
	
	level_string += value_util.encode_value(area.sky) + ","
	level_string += value_util.encode_value(area.background) + ","
	level_string += value_util.encode_value(area.music) + ","
	level_string += value_util.encode_value(area.gravity) + ","
	level_string += value_util.encode_value(area.background_palette) + ","
	level_string += value_util.encode_value(area.timer) + ","
	level_string += value_util.encode_value(area.name) + ","
	level_string += value_util.encode_value(area.underwater_music) + "~"
	
	var tiles := []
	var very_background_tiles := []
	var background_tiles := []
	var foreground_tiles := []

	
	level_code_util.generate_from_chunks(area.tile_chunks, [background_tiles, tiles, foreground_tiles, very_background_tiles], area.bounds)
	# Tiles
	var saved_tiles = level_code_util.encode(tiles, area.bounds.size)
	var saved_very_background_tiles = level_code_util.encode(very_background_tiles, area.bounds.size)
	var saved_background_tiles = level_code_util.encode(background_tiles, area.bounds.size)
	var saved_foreground_tiles = level_code_util.encode(foreground_tiles, area.bounds.size)
	
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
		
		added_object += value_util.encode_value(value_util.get_true_value(object.properties[0]-area.bounds.position*32)) + ","
		for i in range(1,object.properties.size()):
			added_object += value_util.encode_value(value_util.get_true_value(object.properties[i])) + ","
		added_object.erase(added_object.length() - 1, 1)
		level_string += added_object + "|"
	level_string.erase(level_string.length() - 1, 1)
	return level_string
