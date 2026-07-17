class_name LevelCodeTokenizer
extends Object


const METADATA_PATTERN = "\\{([^{}]*)\\}"
const DATA_PATTERN = "(?:[^\\[\\],]+|\\[[^\\]]*\\])+"
const DICTIONARY_ENTRY_PATTERN = "(?:[^\\[\\]:]+|\\[[^\\]]*\\])+"
const array_data_pattern = "\\{(?:[^{}]++|\\{[^{}]*\\})*\\}"


#probably wont be necessary..
static func splice_level(code: String):
	return get_outermost_brackets(code)[0]


# takes full level code
static func splice_level_components(code: String):
	return get_outermost_brackets(code)


# takes list of area codes
static func splice_areas(code: String):
	return get_outermost_brackets(code)


# takes code of one area
static func splice_area_components(code: String):
	return get_outermost_brackets(code)


# takes list of layer codes
static func splice_layers(code: String):
	return get_outermost_brackets(code)


# takes code of one layer
static func splice_layer_components(code: String):
	return get_outermost_brackets(code)


# takes code of all tiles
static func splice_tiles(code: String):
	return get_outermost_brackets(code)


# takes code of all objects
static func splice_objects(code: String):
	return get_outermost_brackets(code)


# takes code of one object
static func splice_object(code: String):
	return get_outermost_brackets(code)[0]


# Pass any type into this to get its metadata.
static func splice_metadata(code: String):
	var regex = RegEx.new()
	regex.compile(METADATA_PATTERN)
	return regex.search(code).get_string(1)


# Used to get a list of primitive data types
static func splice_data(code: String):
	var regex = RegEx.new()
	regex.compile(DATA_PATTERN)
	return regex_match_to_string_array(regex.search_all(code))


# Handles extracting the items in an array data type
static func splice_data_array(code: String):
	return get_outermost_brackets(code)[0]


# Used to get a list of key-value pairs
static func splice_dictionary(code: String):
	return get_outermost_brackets(code)


# Used to get an 2 element array that represents a key-value pair
static func splice_dictionary_entry(code: String):
	return code.split(":")


static func regex_match_to_string_array(matches: Array) -> Array:
	var result = []
	for mat in matches:
		result.push_back(mat.get_string(0))
	return result


# get brackets on the outmost layer, and ignore everything within curly braces
static func get_outermost_brackets(text: String) -> Array:
	var results: Array = []
	var depth := 0
	var start := -1
	var in_braces := 0 

	for i in text.length():
		var c := text[i]
		
		# Track curly brace depth
		if c == "{":
			in_braces += 1
		elif c == "}":
			if in_braces > 0:
				in_braces -= 1

		elif in_braces == 0:
			if c == "[":
				if depth == 0:
					start = i + 1  
				depth += 1
			elif c == "]":
				depth -= 1
				if depth == 0 and start != -1:
					results.append(text.substr(start, i - start))  
					start = -1
	
	return results
