class_name LevelCodeTokenizer

const level_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const level_components_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const area_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const area_components_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const layer_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const layer_components_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const tile_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const objects_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const object_pattern = "\\[(?:[^\\[\\]]+|\\[[^\\[\\]]*\\])*\\]"
const metadata_pattern = "\\{(?:[^{}]++|\\{[^{}]*\\})*\\}"
const data_pattern = "^((?:[^[\\],]|\\[[^\\]]*\\])*)"
const array_data_pattern = "\\{(?:[^{}]++|\\{[^{}]*\\})*\\}"


#probably wont be necessary..
static func splice_level(code: String):
	var regex = RegEx.new()
	regex.compile(level_pattern)
	return regex.search(code).get_string()
	
# takes full level code
static func splice_level_components(code: String):
	var regex = RegEx.new()
	regex.compile(area_pattern)
	return regex_match_to_string_array(regex.search_all(code))
	
# takes list of area codes
static func splice_areas(code: String):
	var regex = RegEx.new()
	regex.compile(area_components_pattern)
	return regex_match_to_string_array(regex.search_all(code))
	
# takes code of one area
static func splice_area_components(code: String):
	var regex = RegEx.new()
	regex.compile(layer_pattern)
	return regex_match_to_string_array(regex.search_all(code))
	
# takes list of layer codes
static func splice_layers(code: String):
	var regex = RegEx.new()
	regex.compile(layer_pattern)
	return regex_match_to_string_array(regex.search_all(code))
	
# takes code of one layer
static func splice_layer_components(code: String):
	var regex = RegEx.new()
	regex.compile(layer_components_pattern)
	return regex_match_to_string_array(regex.search_all(code))

# takes code of all tiles
static func splice_tiles(code: String):
	var regex = RegEx.new()
	regex.compile(tile_pattern)
	return regex_match_to_string_array(regex.search_all(code))
	
# takes code of all objects
static func splice_objects(code: String):
	var regex = RegEx.new()
	regex.compile(objects_pattern)
	return regex_match_to_string_array(regex.search_all(code))
	
# takes code of one object
static func splice_object(code: String):
	var regex = RegEx.new()
	regex.compile(object_pattern)
	return regex.search(code).get_string()
	
# Pass any type into this to get its metadata.
static func splice_metadata(code: String):
	var regex = RegEx.new()
	regex.compile(metadata_pattern)
	return regex.search(code).get_string()

# Used to get a list of primitive data types
static func splice_data(code: String):
	var regex = RegEx.new()
	regex.compile(data_pattern)
	return regex_match_to_string_array(regex.search_all(code))
	
# Handles extracting the items in an array data type
static func splice_data_array(code: String):
	var regex = RegEx.new()
	regex.compile(data_pattern)
	return regex.search(code).get_string()
	
static func regex_match_to_string_array(matches: Array) -> Array:
	var result = []
	for mat in matches:
		result.push_back(mat.get_string())
	return result
	

