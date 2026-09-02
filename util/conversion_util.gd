class_name conversion_util


static func convert_040_to_041(result):
	result.format_version = "0.4.1"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			
			if !area_result.has("objects"):
				break
			
			var new_objects = []
			area_result.music = int(area_result.music)
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
			
			if !area_result.has("objects"):
				break
			
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
			
			if !area_result.has("objects"):
				break
			
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
	var door_container = []
	var current_id = 0
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			
			if !area_result.has("objects"):
				break
			
			var new_objects = []
			for object_result in area_result.objects:
				var object = object_result
				if object.type_id == 23: #chad hardcoding
					object.properties[0].y += 4
				elif object.type_id == 48:
					object.properties.resize(8)
					door_container.append(object)
					continue
				new_objects.append(object)
			
			if door_container != null:
				var door_pairs = []
				var pair_id = 0
				for object in door_container:
					var ref_tag = object.properties[5]
					for obj in door_container:
						if obj.properties[6] == ref_tag && obj.properties[6] != "default":
							var new_tag = "converted_door_pair" + str(pair_id)
							obj.properties[7] = new_tag
							object.properties[7] = new_tag
							pair_id += 1
							obj.properties[6] = new_tag
							obj.properties[5] = new_tag
							object.properties[6] = new_tag
							object.properties[5] = new_tag
				for j in door_container:
					new_objects.append(j)
			area_result.objects = new_objects
	return result


static func convert_048_to_049(result):
	result.format_version = "0.4.9"
	var current_id = 0
	for area_result in result.areas:
		for layer in ["foreground_tiles", "very_foreground_tiles", "background_tiles", "very_background_tiles"]:
			for chunk in area_result[layer].size():
				if get_chunk_tile_id(area_result[layer][chunk]) == "08":
					area_result[layer][chunk] = set_chunk_tile_id(area_result[layer][chunk], "35") #gigachad hardcoding
		if typeof(area_result) == TYPE_DICTIONARY:
			var new_objects = []
			for object_result in area_result.objects:
				var object = object_result
				if object.type_id == 48: #===============================================
					object.properties.resize(8)
					var new_tag = "default_teleporter"
					if typeof(object.properties[7]) == TYPE_STRING:
						new_tag = object.properties[7]  #This is why we need a rewrite
					object.properties[5] = 0
					if object.properties[6] == "default_teleporter" || object.properties[6] == "none":
						object.properties[6] = new_tag
					object.properties[7] = false
					#print(object)
				new_objects.append(object)
			area_result.objects = new_objects #==========================================
	return result


static func convert_049_to_050(result):
	result.format_version = "0.5.0"
	result.author = "Unknown"
	result.description = "This level has no description."
	result.thumbnail_url = ""
#	for result_area in result.areas:
#		result_area.timer = 0.00
	return result


static func convert_051_to_052(result):
	result.format_version = "0.5.2"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			
			if !area_result.has("objects"):
				break
			
			var new_objects : Array = []
			for object_result in area_result.objects:
				var object = object_result
				#liquid conversion (oh boy let the fun begin)
				match(object.type_id):
					72: #water
						var old_properties = object.properties.duplicate()
						object.properties.resize(12)
						object.properties[5] = Vector2(old_properties[5], old_properties[6]) #convert width and height to single vector2
						object.properties[6] = old_properties[7] #move subsequent properties forward: color, render in front, tag
						object.properties[7] = old_properties[8]
						object.properties[8] = old_properties[9]
						object.properties[9] = true if old_properties.size() < 12 else old_properties[11] #tap mode (checks if property is present, if it isn't it just sets it to true)
						object.properties[10] = true #waves enable (defaults to true)
						object.properties[11] = old_properties[10] #water toxicity
					75: #lava
						var old_properties = object.properties.duplicate()
						object.properties.resize(14)
						object.properties[5] = Vector2(old_properties[5], old_properties[6])
						object.properties[6] = old_properties[7]
						object.properties[7] = old_properties[8]
						object.properties[8] = old_properties[9]
						object.properties[9] = true if old_properties.size() < 11 else old_properties[10]
						object.properties[10] = true
						object.properties[11] = true
						object.properties[12] = true
						object.properties[13] = Color8(255, 195, 0, 255)
					142: #quicksand (from before liquids were finished)
						var old_properties = object.properties.duplicate()
						object.properties.resize(13)
						object.properties[5] = old_properties[5]
						object.properties[6] = old_properties[6]
						object.properties[7] = old_properties[7]
						object.properties[8] = old_properties[8]
						object.properties[9] = old_properties[9]
						object.properties[10] = old_properties[12]
						object.properties[11] = old_properties[13]
						object.properties[12] = old_properties[14]
				
				new_objects.append(object)
			area_result.objects = new_objects

	return result


static func convert_052_to_053(result):
	result.format_version = "0.5.3"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			
			if !area_result.has("objects"):
				break
			
			var new_objects = []
			for object_result in area_result.objects:
				var object = object_result
				object.properties.insert(5, 2)
				
				if object.type_id == 82: #checkpoint conversion
					var old_properties = object.properties.duplicate()
					object.properties[7] = Vector2(0, old_properties[7])
				
				new_objects.append(object)
			area_result.objects = new_objects
	return result


static func convert_053_to_054(result):
	result.format_version = "0.5.4"
	return result


static func convert_054_to_055(result):
	result.format_version = "0.5.5"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			
			if !area_result.has("objects"):
				break
			
			var new_objects : Array = []
			for object_result in area_result.objects:
				var object = object_result
				# teleporter conversion (property indexes are gonna make me go insane i swear
				match(object.type_id):
					23: # pipe
						object.properties.resize(12)
						var color = object.properties[8]
						var teleport_mode = object.properties[9]
						var force_fadeout = object.properties[10]
						object.properties[11] = color
						object.properties[8] = int(teleport_mode) # true = remote, false = local (why was it that way :/)
						object.properties[9] = 0 if force_fadeout == true else 800 # setting max pan distance to 0 acts the same as force fadeout
						object.properties[10] = ""
					
					29: # goomba
						object.properties[0] += Vector2(0, 25)
						
					48: # door
						object.properties.resize(10)
						var teleport_mode = object.properties[8]
						var force_fadeout = object.properties[9]
						object.properties[8] = int(teleport_mode) # true = remote, false = local
						object.properties[9] = 0 if force_fadeout == true else 800 # setting max pan distance to 0 acts the same as force fadeout
						
					112: # area transition:
						object.properties.resize(14)
						var teleport_mode = object.properties[8]
						var vertical = object.properties[9]
						var parts = object.properties[10]
						var stops_camera = object.properties[11]
						var force_fadeout = object.properties[12]
						object.properties[8] = int(teleport_mode) # true = remote, false = local (why was it that way :/)
						object.properties[9] = 0 if force_fadeout == true else 800 # setting max pan distance to 0 acts the same as force fadeout
						object.properties[10] = ""
						object.properties[11] = vertical
						object.properties[12] = parts
						object.properties[13] = stops_camera
		
						
					113: # star door
						object.properties.resize(15)
						var teleport_mode = object.properties[8]
						var collectible = object.properties[9]
						var required_amount = object.properties[10]
						var insufficient_text = object.properties[11]
						var is_single = object.properties[12]
						object.properties[8] = int(teleport_mode) # true = remote, false = local
						object.properties[9] = 800 # max pan distance - just setting back to defaults so they arent borked
						object.properties[10] = "" # level path
						object.properties[11] = collectible
						object.properties[12] = required_amount
						object.properties[13] = insufficient_text
						object.properties[14] = is_single
						
					124: #buoyant platform
						object.properties[0] += Vector2(0, 15 * -object.properties[1].y)
					
				
				new_objects.append(object)
			area_result.objects = new_objects
	return result

static func is_pre_100(level_code: String) -> bool:
	return level_code.begins_with("0")

static func get_level_metadata_from_old_data(level_data) -> LevelMetadata:
	var starting_area: AreaDataOld = level_data.areas[0]
	return LevelMetadata.new(
		level_data.name,
		level_data.author,
		level_data.description,
		level_data.thumbnail_url,
		starting_area.sky,
		starting_area.background,
		starting_area.background_palette,
		100,
		get_collectible_data_from_old_data(level_data)
	)


static func get_collectible_data_from_old_data(level_data) -> CollectibleData:
	var mission_datas: Array = []
	var star_coin_datas: Array = []
	var used_mission_datas: Dictionary = {}
	
	var SHINE_ID: int = 2
	var STAR_COIN_ID: int = 52
	
	for area in level_data.areas:
		area = area as AreaDataOld
		for object in area.objects:
			object = object as ObjectDataOld
			var properties: Array = object.properties.duplicate(true)
			
			if object.type_id == SHINE_ID:
				var mission_data: MissionData = MissionData.new(
					uuid_util.v4(),
					properties[8], # Show in menu
					properties[6], # Shine name
					properties[7], # Shine desc
					properties[15], # Sort order
					properties[12], # Color
					properties[14], # Kick out
					0,
					"spawn"
				)
				
				object.properties = properties.slice(0, 5)
				object.properties.resize(13)
				object.properties[6] = properties[9]
				object.properties[7] = properties[10]
				object.properties[8] = properties[11]
				object.properties[9] = mission_data.mission_uuid
				object.properties[10] = 0 if properties.size() <= 16 else properties[16]
				object.properties[11] = ""
				
				mission_datas.append(mission_data)
				used_mission_datas[mission_data.mission_uuid] = 1
			elif object.type_id == STAR_COIN_ID:
				var star_coin_data: StarCoinData = StarCoinData.new(
					uuid_util.v4(),
					StarCoinData.DEFAULT_HINT,
					StarCoinData.DEFAULT_COLOR
				)
				
				object.properties[6] = star_coin_data.star_coin_uuid
				
				star_coin_datas.append(star_coin_data)
	
	return CollectibleData.new(mission_datas, star_coin_datas, 0, used_mission_datas, false, [])


static func get_area_data_from_old_data(old_area: AreaDataOld) -> AreaData:
	var area_header := AreaHeader.new(
		"",
		old_area.bounds,
		old_area.name,
		old_area.sky,
		old_area.background,
		old_area.background_palette,
		old_area.bg_autoscroll_speed,
		old_area.gravity,
		old_area.timer,
		old_area.music,
		old_area.underwater_music
	)
	
	area_header.show_name = false
	area_header.show_song = false
	area_header.minimum_timer = -1
	
	return get_new_area_code(area_header, old_area)

static func get_area_headers_from_old_data(level_data) -> Array:
	var area_headers: Array = []
	
	var area_header: AreaHeader
	for old_area in level_data.areas:
		old_area = old_area as AreaDataOld
		area_header = AreaHeader.new(
			"",
			old_area.bounds,
			old_area.name,
			old_area.sky,
			old_area.background,
			old_area.background_palette,
			old_area.bg_autoscroll_speed,
			old_area.gravity,
			old_area.timer,
			old_area.music,
			old_area.underwater_music
		)
		
		area_header.show_name = false
		area_header.show_song = false
		area_header.minimum_timer = -1
		area_header.area_code = LevelCodeSerializer.serialize_area(get_new_area_code(area_header, old_area))
		
		area_headers.append(area_header)
	
	return area_headers


static func get_new_area_code(header: AreaHeader, old_area: AreaDataOld) -> AreaData:
	var area_data: AreaData = AreaData.new(header, [])
	
	var BACKGROUND_TINT: Color = Color(0.545098, 0.545098, 0.545098)
	
	# ahh the last time VeryBack's cursed layer index will ever get to haunt me...
	var layers: Dictionary = {
		3: LayerData.new(LayerMetadata.new(0, Vector2.ZERO, false, BACKGROUND_TINT, 0, false, "Very Back", false), TileData.new()),
		0: LayerData.new(LayerMetadata.new(0, Vector2.ZERO, false, BACKGROUND_TINT, 1, false, "Background", false), TileData.new()),
		1: LayerData.new(LayerMetadata.new(0, Vector2.ZERO, false, Color.white, 2, true, "Ground", true), TileData.new()),
		2: LayerData.new(LayerMetadata.new(0, Vector2.ZERO, false, Color.white, 3, false, "Foreground", false), TileData.new()),
	}
	
	var object_layer_map: Array = [3, 0, 1, 2]
	
	for chunk_key in old_area.tile_chunks:
		chunk_key = chunk_key as String
		var layer: int = int(chunk_key.split(":")[2])
		var layer_data: LayerData = layers[layer]
		var chunk_coord: Vector2 = Vector2(int(chunk_key.split(":")[0]), int(chunk_key.split(":")[1]))
		var new_chunk_data: PoolIntArray = PoolIntArray()
		for tile in old_area.tile_chunks.get(chunk_key):
			if tile != null:
				new_chunk_data.append(tile_util.get_packed_tile(tile[0], tile[1], tile[2]))
			else:
				new_chunk_data.append(0)
		
		layer_data.tile_data.set_chunk_data(chunk_coord, new_chunk_data)
	
	for old_object in old_area.objects:
		old_object = old_object as ObjectDataOld
		var object_layer: int = object_layer_map[old_object.properties.pop_at(5)]
		var position: Vector2 = old_object.properties.pop_at(0)
		
		if old_object.type_id == 14: # sign
			if old_object.properties[5] == true: # is background
				object_layer = 0
		if old_object.type_id == 29: # goomba
			old_object.properties.resize(10)
			var color = old_object.properties[4]
			position += Vector2(0, -3)
			old_object.properties[4] = float(15)
			old_object.properties[5] = 0
			old_object.properties[6] = 1
			old_object.properties[7] = Vector2.ZERO
			old_object.properties[8] = float(0)
			old_object.properties[9] = color
		if old_object.type_id == 49: # touch lift
			if old_object.properties.size() == 10:
				old_object.properties.resize(13)
				old_object.properties[10] = int(0)
				old_object.properties[11] = old_object.properties[6].duplicate(true)
				old_object.properties[12] = float(0)
		if old_object.type_id == 113: # star door
			old_object.properties.insert(11, "")
		
		var property_dictionary: Dictionary = {}
		for i in old_object.properties.size():
			var value = old_object.properties[i]
			# can't get all the default properties but we can at least check the old
			# base ones and not include them if they're unchanged
			match i:
				0: # scale
					if value is Vector2 and value != Vector2.ONE:
						property_dictionary.get_or_add(i, old_object.properties[i])
				1: # rotation degrees
					if value is float and !is_zero_approx(value):
						property_dictionary.get_or_add(i, old_object.properties[i])
				2: # enabled
					if value is bool and value != true:
						property_dictionary.get_or_add(i, old_object.properties[i])
				3: # visible
					if value is bool and value != true:
						property_dictionary.get_or_add(i, old_object.properties[i])
				_:
					property_dictionary.get_or_add(i, old_object.properties[i])
		
		property_dictionary.get_or_add(-3, object_layer == 0 or object_layer == 3) # in front
		
		if old_object.type_id == 75: # Lava
			property_dictionary[10] = true # use old lava
		
		var new_object: ObjectData = ObjectData.new(
			ObjectMetadata.new(
				position,
				old_object.type_id,
				old_object.palette
			), 
			property_dictionary
		)
		layers[object_layer].object_data.append(new_object)
	
	area_data.layers = layers.values()
	
	return area_data


static func get_new_level_data_from_old_data(level_data) -> LevelDataContainer:
	var container: LevelDataContainer = LevelDataContainer.new(
		get_level_metadata_from_old_data(level_data),
		EditorData.new(),
		get_area_headers_from_old_data(level_data),
		get_level_tags_from_old_data(level_data)
	)
	
	return container

static func get_level_tags_from_old_data(level_data) -> LevelTags:
	var level_tags := LevelTags.new()
	for area in level_data.areas:
		for object in area.objects:
			if (object.type_id == 23 or
				object.type_id == 48 or
				object.type_id == 112 or
				object.type_id == 113): # Door, Pipe, Area Transition, and Star Door
				if not object.properties[5] in level_tags.teleport_tags:
					level_tags.teleport_tags.append(object.properties[5])
			if (object.type_id == 72 or
				object.type_id == 75): # Water and Lava
				if not object.properties[7] in level_tags.liquid_tags:
					level_tags.liquid_tags.append(object.properties[7])
			if object.type_id == 81: # Crystal Tap
				if not object.properties[4] in level_tags.liquid_tags:
					level_tags.liquid_tags.append(object.properties[4])
			if (object.type_id == 127 or
				object.type_id == 137 or
				object.type_id == 138 or
				object.type_id == 139): # Toad, Peach, Yoshi, and Red Bob-omb
				if not object.properties[14] in level_tags.dialogue_tags:
					level_tags.dialogue_tags.append(object.properties[14])
			if object.type_id == 128: # Dialogue Trigger
				if not object.properties[10] in level_tags.dialogue_tags:
					level_tags.dialogue_tags.append(object.properties[10])
	return level_tags

static func compare_versions(version, other) -> int:
	var v = version.split(".")
	var o = other.split(".")
	
	if (len(v) != 3 or len(o) != 3):
		return -1
	for i in range(3):
		var nv = int(v[i])
		var no = int(o[i])
		if(nv < no):
			return -1 # smaller version
		# so originally this was a lower than symbol again instead of a greater than symbol like it should be?
		# that caused me quite a fair deal of annoyance... and it was over one character,, (dies)
		if(nv > no):
			return 1 # bigger version

	return 0 # same version


static func get_chunk_tile_id(chunk : String):
	var chunk_parts
	if "*" in chunk: 
		chunk_parts = chunk.split("*")
	else: 
		chunk_parts = [chunk, ""]
	if ":" in chunk_parts[0]:
		var tile = chunk_parts[0].split(":")
		tile[0] = str(tile[0])
		tile[1] = str(tile[1]) #For some weird reason, .split() doesn't always carry over the agument's type
		return tile[1].left(2)
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
		var tile = chunk_parts[0].split(":")
		tile[0] = str(tile[0])
		tile[1] = str(tile[1]) #For some weird reason, .split() doesn't always carry over the agument's type
		tile[1] = new_id + chunk_parts[0][1].right(2)
		chunk_parts[0] = tile[0] + ":" + tile[1]
	chunk_parts[0] = new_id + chunk_parts[0].right(2)
	var reconstituted = ""
	for i in chunk_parts.size():
		reconstituted += chunk_parts[i]
	return reconstituted
