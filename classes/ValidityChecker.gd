extends LevelData
class_name ValidityChecker

const INFO_DATA_SUFFIX: String = "~0*0~0*0~0*0~0*0]"
const MULTIPLAYER_INVALID_OBJECTS: Array = [145] # List of object IDs invalid with multiplayer
enum ValidityCheckTypes {INIT = 0,NONE = 1,INFO = 2,FULL = 3}

var is_valid: bool = true
var is_level_multiplayer_compatible: bool = true
var invalid_reason: String
var level_code: String
var result: Dictionary = {}

export (ValidityCheckTypes) var validity_check_type = -1

func _init(code: String = "",type: int = 0)-> void:
	
	._init("", true)
	
	if ValidityCheckTypes.find_key(type) == null:
		printerr("Invalid validity check type passed!\n"+"Valid values: ",ValidityCheckTypes.values(),
		"\nSetting validity check to None.")
		validity_check_type = ValidityCheckTypes.NONE
	
	else:
		validity_check_type = type
	
	level_code = code

func check_validity()-> void:
	
	result = {}
	is_valid = false
	invalid_reason = "This level has not been checked for validity yet."
	
	match (validity_check_type):
		
		ValidityCheckTypes.INFO:
			info_check()
			
		ValidityCheckTypes.FULL:
			full_check()
			
		ValidityCheckTypes.INIT: # For initialisation cases
			vars = LevelVars.new()
			level_code = level_list_util.load_level_code_file(DEFAULT_CODE_PATH)
			full_check()
		
		ValidityCheckTypes.NONE:
			push_warning("Warning! Validity check is None, level code will not be verified.")

func is_object_multiplayer_compatible(id: int,caller: Object)-> bool:
	
	var is_multiplayer: bool = Singleton.PlayerSettings.number_of_players > 1
	var has_object: bool = MULTIPLAYER_INVALID_OBJECTS.has(id)
	
	if (has_object):
		is_level_multiplayer_compatible = false
		if (caller != self):
			Singleton.PlayerSettings.number_of_players = 1
	
	if (!is_multiplayer and caller == self):
		return true
	
	return !has_object

func get_object_name(id: int)-> String:
	
	return Singleton.CurrentLevelData.object_id_map.ids[id]

## this function makes it so we can get info about a level for
## its card without loading everything in the level and wasting
## processing power :3
func get_info_level_code(code: String)-> String:
	
	var first_bracket_index: int = code.find("[")
	var first_end_bracket_index: int = code.find("]")
	
	var level_code_start: String = code.left(first_bracket_index + 1)
	code.erase(first_bracket_index, first_end_bracket_index - first_bracket_index)
	code.erase(0, first_bracket_index)
	
	var info_level_code = level_code_start + code.get_slice("~", 0)
	info_level_code += INFO_DATA_SUFFIX
	
	return info_level_code

static func decode_info(code: String)-> Dictionary:
	var info_result: Dictionary = {}
	
	code = code.strip_edges()
	var code_array: Array = code.split(",")
	
	info_result.format_version = code_array[0]
	if (code_array.size() > 1):
		info_result.name = code_array[1].percent_decode()
	else:
		info_result.invalid_reason = "No level name found in level code."
		return info_result
	
	
	var add_amount = 1
	if info_result.format_version == "0.4.0" or info_result.format_version == "0.4.1":
		add_amount = 0
	
	elif conversion_util.compareVersions(info_result.format_version, "0.5.0") > -1:
		info_result.author = code_array[2].percent_decode()
		info_result.description = code_array[3].percent_decode()
		info_result.thumbnail_url = code_array[4].percent_decode()
		add_amount = 4
	
	if (code_array.size() < 5 + add_amount):
		info_result.invalid_reason = "Couldn't find area settings for area ID 0."
		return info_result
	
	var area_index: int = 2 + add_amount
	info_result.areas = [{}]
	info_result.areas[0].settings = {}
	info_result.areas[0].settings.sky = value_util.decode_value(code_array[area_index + 1])
	info_result.areas[0].settings.background = value_util.decode_value(code_array[area_index + 2])
	info_result.areas[0].settings.background_palette = 0
	
	if conversion_util.compareVersions(info_result.format_version, "0.4.6") == 1:
		var split: String = code_array[area_index + 5].get_slice("~", 0)
		info_result.areas[0].settings.background_palette = value_util.decode_value(split)
	
	return info_result

func info_check()-> void:
	
	if (level_code == null or level_code.length() == 0):
		invalid_reason = "This level has no level code associated with it."
		return
	
	var info_level_code: String = get_info_level_code(level_code)
	
	if (info_level_code == null):
		invalid_reason = "Could get level info from code."
		return
	
	result = decode_info(info_level_code)
	
	if (result.has("invalid_reason")):
		invalid_reason = result.invalid_reason
		return
	
	if (result.size() < 3): # Don't actually know what would cause this
		invalid_reason = "This level has an invalid level code."
		return
	
	if (typeof(result.areas[0].settings.sky) != TYPE_INT or
	typeof(result.areas[0].settings.background) != TYPE_INT or
	typeof(result.areas[0].settings.background_palette) != TYPE_INT):
		invalid_reason = "Area settings for area ID 0 are invalid."
		return
	
	is_valid = true

func decode(code: String)-> Dictionary:
	
	var full_result = {}
	
	code = code.strip_edges()
	code = code.replace("\n", "")
	var code_array = level_code_util.split_code_top_level(code)
	
	if (code_array.size() < 4):
		full_result = {"decode_error":true}
		invalid_reason = "Level code missing required parts. (Code version, Level Name, Hotbar/Pin, or Area data)"
		return full_result
	
	full_result.format_version = code_array[0]
	full_result.name = code_array[1].percent_decode()
	
	var add_amount = 1
	var layout_array: Array
	var pins_array: Array
	
	
	if full_result.format_version == "0.4.0" or full_result.format_version == "0.4.1":
		add_amount = 0
	
	elif conversion_util.compareVersions(full_result.format_version, "0.5.0") > -1:
		full_result.author = code_array[2].percent_decode()
		full_result.description = code_array[3].percent_decode()
		full_result.thumbnail_url = code_array[4].percent_decode()
		
		var editor_array: Array = code_array[5].split("^")
		if editor_array.size() > 1:
			layout_array = editor_array[0].split(",")
			pins_array = editor_array[1].split(",")
		
		add_amount = 4
	
	
	var layout_ids: Array = []
	var layout_palettes: Array = []
	var pinned_items: Array = []
	
	var starting_toolbar = preload("res://scenes/oldeditor/starting_toolbar.tres")
	for index in range(starting_toolbar.ids.size()):
		layout_ids.append(starting_toolbar.ids[index])
		layout_palettes.append(0)
	
	for index in range(layout_array.size()):
		var item: String = layout_array[index]
		var palette := int(item[0])
		item.erase(0, 1)
		
		layout_ids[index] = item
		layout_palettes[index] = palette
		
	for index in range(pins_array.size()):
		var item: String = pins_array[index]
		if item != "":
			var palette := int(item[0])
			item.erase(0, 1)
			
			var pin_array: Array = []
			pin_array.append(item)
			pin_array.append(palette)
			pinned_items.append(pin_array)
	
	full_result.layout_ids = layout_ids
	full_result.layout_palettes = layout_palettes
	full_result.pinned_items = pinned_items
	
	
	var areas = code_array.size() - (2 + add_amount)
	
	full_result.areas = []
	
	for area_id in range(areas):
		var area_index = (2 + add_amount) + area_id
		
		var area_array = code_array[area_index].split("~")
	
		var area_settings_array = area_array[0].split(",")
		
		if (area_settings_array.size() < 4):
			full_result = {"decode_error":true}
			invalid_reason = "Area ID: "+String(area_id)\
			+" missing required value(s)- foreground, background, "\
			+"music, or gravity."
			return full_result
		
		full_result.areas.append({})
		full_result.areas[area_id].settings = {}
		full_result.areas[area_id].settings.size = value_util.decode_value(area_settings_array[0])
		full_result.areas[area_id].settings.sky = value_util.decode_value(area_settings_array[1])
		full_result.areas[area_id].settings.background = value_util.decode_value(area_settings_array[2])
		full_result.areas[area_id].settings.music = value_util.decode_value(area_settings_array[3])
		if area_settings_array.size() > 4:
			full_result.areas[area_id].settings.gravity = value_util.decode_value(area_settings_array[4])
		else:
			full_result.areas[area_id].settings.gravity = 7.82
		
		if area_settings_array.size() > 5:
			full_result.areas[area_id].settings.background_palette = value_util.decode_value(area_settings_array[5])
		else:
			full_result.areas[area_id].settings.background_palette = 0
		
		if area_settings_array.size() > 6:
			full_result.areas[area_id].settings.timer = value_util.decode_value(area_settings_array[6])
		else:
			full_result.areas[area_id].settings.timer = 0.00
			
		if area_settings_array.size() > 7:
			full_result.areas[area_id].settings.name = value_util.decode_value(area_settings_array[7])
		else:
			full_result.areas[area_id].settings.name = ""
		
		
		if(conversion_util.compareVersions(full_result.format_version, "0.4.5") == -1):
			area_array.insert(2,"0*0")
		
		var area_tiles_array = area_array[1].split(",")
		full_result.areas[area_id].foreground_tiles = []
		for tile in area_tiles_array:
			full_result.areas[area_id].foreground_tiles.append(tile)
			
		var area_very_background_tiles_array = area_array[2].split(",")
		full_result.areas[area_id].very_background_tiles = []
		for tile in area_very_background_tiles_array:
			full_result.areas[area_id].very_background_tiles.append(tile)

		var area_background_tiles_array = area_array[3].split(",")
		full_result.areas[area_id].background_tiles = []
		for tile in area_background_tiles_array:
			full_result.areas[area_id].background_tiles.append(tile)
			
		var area_foreground_tiles_array = area_array[4].split(",")
		full_result.areas[area_id].very_foreground_tiles = []
		for tile in area_foreground_tiles_array:
			full_result.areas[area_id].very_foreground_tiles.append(tile)
			
		full_result.areas[area_id].objects = []
		if area_array.size() > 5:
			var objects_array = area_array[5].split("|")
			for object in objects_array:
				var object_array = object.split(",")
				var decoded_object = {}
				decoded_object.properties = []
				decoded_object.type_id = int(object_array[0])
				if (!is_object_multiplayer_compatible(decoded_object.type_id,self)):
					full_result = {"decode_error":true}
					invalid_reason = "Area ID: "+String(area_id)\
					+" has an object incompatible with multiplayer ("\
					+get_object_name(decoded_object.type_id)+")\nPlease turn off multiplayer to play"\
					+" or edit this level."
					return full_result
				var start_index = 1
				if (conversion_util.compareVersions(full_result.format_version, "0.4.7") != -1):
					decoded_object.palette = int(object_array[1])
				else:
					start_index = 0
					decoded_object.palette = 0
				var index = 0
				for value in object_array:
					if index > start_index:
						decoded_object.properties.append(value_util.decode_value(value))
					index += 1
				full_result.areas[area_id].objects.append(decoded_object)
	
	return full_result
	
func decode_area(area: String):
	var area_array = area.split("~")
	var area_settings_array = area_array[0].split(",")
	var full_result = {}
	
	if (area_settings_array.size() < 4):
		full_result = {"decode_error":true}
		invalid_reason = "Area"\
		+" missing required value(s)- foreground, background, "\
		+"music, or gravity."
		return full_result
	
	full_result.settings = {}
	full_result.settings.size = value_util.decode_value(area_settings_array[0])
	full_result.settings.sky = value_util.decode_value(area_settings_array[1])
	full_result.settings.background = value_util.decode_value(area_settings_array[2])
	full_result.settings.music = value_util.decode_value(area_settings_array[3])
	if area_settings_array.size() > 4:
		full_result.settings.gravity = value_util.decode_value(area_settings_array[4])
	else:
		full_result.settings.gravity = 7.82
	
	if area_settings_array.size() > 5:
		full_result.settings.background_palette = value_util.decode_value(area_settings_array[5])
	else:
		full_result.settings.background_palette = 0
	
	if area_settings_array.size() > 6:
		full_result.settings.timer = value_util.decode_value(area_settings_array[6])
	else:
		full_result.settings.timer = 0.00
		
	if area_settings_array.size() > 7:
		full_result.settings.name = value_util.decode_value(area_settings_array[7])
	
	
	var area_tiles_array = area_array[1].split(",")
	full_result.foreground_tiles = []
	for tile in area_tiles_array:
		full_result.foreground_tiles.append(tile)
		
	var area_very_background_tiles_array = area_array[2].split(",")
	full_result.very_background_tiles = []
	for tile in area_very_background_tiles_array:
		full_result.very_background_tiles.append(tile)

	var area_background_tiles_array = area_array[3].split(",")
	full_result.background_tiles = []
	for tile in area_background_tiles_array:
		full_result.background_tiles.append(tile)
		
	var area_foreground_tiles_array = area_array[4].split(",")
	full_result.very_foreground_tiles = []
	for tile in area_foreground_tiles_array:
		full_result.very_foreground_tiles.append(tile)
		
	full_result.objects = []
	if area_array.size() > 5:
		var objects_array = area_array[5].split("|")
		for object in objects_array:
			var object_array = object.split(",")
			var decoded_object = {}
			decoded_object.properties = []
			decoded_object.type_id = int(object_array[0])
			if (!is_object_multiplayer_compatible(decoded_object.type_id,self)):
				full_result = {"decode_error":true}
				invalid_reason = "Area"\
				+" has an object incompatible with multiplayer ("\
				+get_object_name(decoded_object.type_id)+")\nPlease turn off multiplayer to play"\
				+" or edit this level."
				return full_result
			var start_index = 1
			start_index = 0
			decoded_object.palette = 0
			var index = 0
			for value in object_array:
				if index > start_index:
					decoded_object.properties.append(value_util.decode_value(value))
				index += 1
			full_result.objects.append(decoded_object)
	return full_result

func load_in(code: String)-> void:
	
	vars = LevelVars.new()
	
	result = decode(code)
	
	if not result.has("format_version"):
		result = {}
		return
	
	var starting_format_version = result.format_version
	
	if (result.has("decode_error")):
		result = {}
		return
	
	if (!LevelData.check_code(result)):
		invalid_reason = "Level has an invalid code structure or is missing required parts."
		result = {}
		return
	
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

	if result.format_version == "0.5.2":
		result = conversion_util.convert_052_to_053(result)
	
	if result.format_version == "0.5.3":
		if starting_format_version == "0.5.3":
			result = conversion_util.convert_053_to_054(result)
		else:
			result.format_version = "0.5.4"
	
	if result.format_version == "0.5.4":
		result = conversion_util.convert_054_to_055(result)

	assert(result.format_version)
	var version_int = result.format_version.replace(".","")
	var format_version = result.format_version
	name = result.name

	if (version_int.is_valid_integer()):
		author = result.author
		description = result.description
		thumbnail_url = result.thumbnail_url
	
	layout_ids = result.layout_ids
	layout_palettes = result.layout_palettes
	pinned_items = result.pinned_items
	
	if format_version == current_format_version:
		areas = []
		for area_result in result.areas:
			if (area_result.size() == 6):
				var area = get_area(area_result)
				
				if is_instance_valid(area):
					areas.append(area)
				else:
					printerr("Found invalid area while parsing level code, area will be skipped.")
			else:
				printerr("Found invalid area while parsing level code, area will be skipped.")
	else:
		print("Outdated format version. Current version is " \
		+ current_format_version + ", but course uses version " + format_version + ".")

func full_check()-> void:
	
	if level_code == "":
		level_code = level_list_util.load_level_code_file(DEFAULT_CODE_PATH)
		
	load_in(level_code)
	
	if (result.size() == 0):
		return
	
	is_valid = true
