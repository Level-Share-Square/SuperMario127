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
	elif type == TYPE_COLOR:
		return "CL" + str(stepify(value.r,0.01)) + "x" + str(stepify(value.g,0.01)) + "x" + str(stepify(value.b,0.01)) + "x" + str(stepify(value.a,0.01))
	elif type == TYPE_BOOL:
		return "BL" + str(0 if value == false else 1)
	elif type == TYPE_INT:
		return "IT" + str(value)
	elif type == TYPE_REAL:
		return "FL" + str(value)
	elif type == TYPE_STRING:
		return "ST" + str(value).percent_encode()
	elif value is Curve2D:
		var curve: Curve2D = value
		var curve_string := "C2"
		for index in range(0,curve.get_point_count()):
			var point = curve.get_point_position(index)
			var point_in = curve.get_point_in(index)
			var point_out = curve.get_point_out(index)
			curve_string += str(stepify(point.x,0.1)) + "x" + str(stepify(point.y, 0.1))
			curve_string += "X"
			
			if(point_in!=Vector2()):
				curve_string += str(stepify(point_in.x,0.1)) + "x" + str(stepify(point_in.y, 0.1))
			curve_string += "X"
			
			if(point_out!=Vector2()):
				curve_string += str(stepify(point_out.x,0.1)) + "x" + str(stepify(point_out.y, 0.1))
				
			curve_string += ":"
			
		curve_string = curve_string.trim_suffix(":")
			
		return curve_string
	elif type == TYPE_STRING_ARRAY:
		var final_string := "SA"
		for text in value:
			final_string += str(text).percent_encode()
			final_string += ":"
		
		final_string = final_string.trim_suffix(":")
		return final_string
	elif type == TYPE_VECTOR2_ARRAY:
		var final_string := "VA"
		for vector in value:
			final_string += str(stepify(vector.x,0.1)) + "x" + str(stepify(vector.y, 0.1))
			final_string += ":"
		
		final_string = final_string.trim_suffix(":")
		return final_string
	else:
		return str(value)

static func decode_value(value: String):
	if value.ends_with("]"):
		value = value.rstrip("]")
		
	if value.begins_with("V2"):
		value = value.trim_prefix("V2")
		var array_value = value.split("x")
		return Vector2(array_value[0], array_value[1])
	elif value.begins_with("CL"):
		value = value.trim_prefix("CL")
		var array_value = value.split("x")
		var color = Color(array_value[0], array_value[1], array_value[2])
		if array_value.size() > 3:
			color.a = float(array_value[3])
		return color
	elif value.begins_with("BL"):
		value = value.trim_prefix("BL")
		return true if value == "1" else false
	elif value.begins_with("IT"):
		value = value.trim_prefix("IT")
		return int(value)
	elif value.begins_with("FL"):
		value = value.trim_prefix("FL")
		return float(value)
	elif value.begins_with("ST"):
		value = value.trim_prefix("ST")
		return str(value).percent_decode()
	elif value.begins_with("C2"):
		value = value.trim_prefix("C2")
		var curve_array = value.split(":")
		var curve : Curve2D = Curve2D.new()
		
		for point in curve_array:
			var point_array = point.split("X")
			curve.add_point(decode_vector(point_array[0]), decode_vector(point_array[1]), decode_vector(point_array[2]))
		
		return curve
	elif value.begins_with("SA"):
		value = value.trim_prefix("SA")
		
		var string_array := PoolStringArray()
		var texts = value.split(":")
		for text in texts:
			string_array.append(str(text).percent_decode())
		
		return string_array
	elif value.begins_with("VA"):
		value = value.trim_prefix("VA")
		
		var vector2_array := PoolVector2Array()
		var vectors = value.split(":")
		for vector in vectors:
			var array_value = vector.split("x")
			var vector2 = Vector2(array_value[0], array_value[1])
			vector2_array.append(vector2)
			
		return vector2_array
	else:
		return value
		
static func decode_vector(value: String) -> Vector2:
	if(value==""):
		return Vector2(0,0)
		
	var array_value = value.split("x")
	return Vector2(array_value[0], array_value[1])
