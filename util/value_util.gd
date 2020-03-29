class_name value_util

static func get_true_value(value):
	if typeof(value) == TYPE_DICTIONARY:
		# very hacky cause i dont know how else to add it
		if value.type == "Vector2":
			return Vector2(value.construction[0], value.construction[1])
	else:
		return value
		
static func get_value_from_true(value):
	# again very hacky cause i dont know how else to add it
	if typeof(value) == TYPE_VECTOR2:
		return {type="Vector2", construction=[value.x, value.y]}
	else:
		return value
		
static func encode_value(value):
	# again very hacky cause i dont know how else to add it
	var type = typeof(value)
	if type == TYPE_VECTOR2:
		return "V2" + str(stepify(value.x,0.1)) + "x" + str(stepify(value.y, 0.1))
	elif type == TYPE_BOOL:
		return "BL" + str(0 if value == false else 1)
	elif type == TYPE_INT:
		return "IT" + str(value)
	elif type == TYPE_REAL:
		return "FL" + str(value)
	elif type == TYPE_STRING:
		return "ST" + str(value).percent_encode()
	else:
		return str(value)
