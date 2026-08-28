class_name level_code_validator_util

# This is to be used for quick level code validation. More accurate validation is done during the decoding step 
static func validate_code(code: String) -> bool:
	if not code: return false
	var bracket_stack: int = 0
	# Currently nested curly braces aren't possible so we just keep track of one pair.
	var in_curly_braces: bool = false
	for i in range(code.length()):
		var character: String = code[i]
		if character == '[' or character == ']' or character == '{' or character=='}':
			if character=='[': bracket_stack += 1
			elif character==']':
				if bracket_stack <= 0: 
					return false
				bracket_stack -= 1
			elif character=='{':
				if i != 0 and (code[i-1] != '[' or in_curly_braces): 
					return false
				in_curly_braces = true
			elif character=='}':
				if !in_curly_braces: 
					return false
				in_curly_braces = false
	if bracket_stack != 0: 
		return false
	return true

static func validate_level_code(code: String) -> bool:
	# stop little timmy from pasting in the wrong thing to the level code entry
	if not code: return false
	if code[0] != '[' and code[code.length()-1] != ']':
		return false
	return validate_code(code)

static func validate_area_code(code: String) -> bool:
	# stop little timmy from pasting in the wrong thing to the areas window
	if not code: return false
	if code[0] != '{' and code[code.length()-1] != ']':
		return false
	return validate_code(code)
