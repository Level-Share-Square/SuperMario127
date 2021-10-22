class_name conversion_util

static func convert_040_to_041(result):
	result.format_version = "0.4.1"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			var new_objects = []
			area_result.settings.music = int(area_result.settings.music)
			for object_result in area_result.objects:
				var object = object_result
				object.properties[2] = int(object.properties[2])
				
				var size = object.properties.size()
				# filling in new properties
				for index in range(size, 5):
					if index == 0:
						object.properties.append(Vector2())
					elif index == 1:
						object.properties.append(Vector2())
					elif index == 2:
						object.properties.append(0)
					elif index == 3:
						object.properties.append(true)
					elif index == 4:
						object.properties.append(true)
				new_objects.append(object)
			area_result.objects = new_objects
	return result

static func convert_042_to_043(result):
	result.format_version = "0.4.3"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			var new_objects = []
			for object_result in area_result.objects:
				var object = object_result
				if object.type_id == 4: #epic hardcoding
					object.properties[0].y += 36
				new_objects.append(object)
			area_result.objects = new_objects
	return result
	
static func convert_044_to_045(result):
	# basically this function recreates the objects dictonary,
	# but changes the shine sprites to have an automatic id
	# it's hacky but we'll be changing this system later anyways
	result.format_version = "0.4.5"
	var current_id = 0
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			var new_objects = []
			for object_result in area_result.objects:
				var object = object_result
				if object.type_id == 2 and object.properties.size() == 10: #epicer hardcoding
					# this code sucks but again we'll be changing the system later
					object.properties.append(false)
					object.properties.append(Color(1, 1, 0))
					object.properties.append(current_id)
					current_id += 1
				elif object.type_id == 13:
					object.type_id = 51
				new_objects.append(object)
			area_result.objects = new_objects
	return result
	
static func convert_047_to_048(result):
	result.format_version = "0.4.8"
	var current_id = 0
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			var new_objects = []
			for object_result in area_result.objects:
				var object = object_result
				if object.type_id == 23: #chad hardcoding
					object.properties[0].y += 4
				new_objects.append(object)
			area_result.objects = new_objects
	return result

static func convert_048_to_049(result):
	result.format_version = "0.4.9"
	var current_id = 0
	for area_result in result.areas.size():
		for layer in ["foreground_tiles", "very_foreground_tiles", "background_tiles", "very_background_tiles"]:
			for chunk in result.areas[area_result][layer].size():
				if get_chunk_tile_id(result.areas[area_result][layer][chunk]) == "08":
					result.areas[area_result][layer][chunk] = set_chunk_tile_id(result.areas[area_result][layer][chunk], "35") #gigachad hardcoding
	return result

static func compareVersions(version, other) -> int:
	var v = version.split(".")
	var o = other.split(".")

	for i in range(3):
		var nv = int(v[i])
		var no = int(o[i])
		if(nv<no):
			return -1 #smaller version
		if(nv<no):
			return 1 #bigger version

	return 0 #same version

static func get_chunk_tile_id(chunk : String):
	var chunk_parts = chunk.split("*")
	if ":" in chunk_parts[0]:
		chunk_parts[0] = chunk_parts[0].split(":")
		return chunk_parts[0][1].left(2)
	else:
		return chunk_parts[0].left(2)
	
static func set_chunk_tile_id(chunk : String, new_id : String):
	var chunk_parts
	if "*" in chunk: 
		chunk_parts = chunk.split("*")
		chunk_parts.insert(1, "*")
	else: 
		chunk_parts = [chunk, ""]
	if ":" in chunk_parts[0]:
		chunk_parts[0] = chunk_parts[0].split(":")
		chunk_parts[0][1] = new_id + chunk_parts[0][1].right(2)
		chunk_parts[0] = chunk_parts[0][0] + ":" + chunk_parts[0][1]
	chunk_parts[0] = new_id + chunk_parts[0].right(2)
	var reconstituted = ""
	for i in chunk_parts.size():
		reconstituted += chunk_parts[i]
	return reconstituted
