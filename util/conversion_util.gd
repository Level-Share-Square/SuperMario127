class_name conversion_util

static func convert_033_to_040(result):	
	var new_result = {}
	new_result.areas = []
	new_result.name = result.name
	new_result.format_version = "0.4.0"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			var area = {}
			area.objects = []
			
			var settings = {}
			settings.sky = area_result.settings.sky
			settings.background = area_result.settings.background
			settings.music = area_result.settings.music + 1 if area_result.settings.music != 0 else 0
			settings.size = Vector2(area_result.settings.size.x, area_result.settings.size.y)
			area.settings = settings
			
			area.background_tiles = []
			area.foreground_tiles = []
			area.very_foreground_tiles = []
			for tile in area_result.very_foreground_tiles:
				tile = tile.substr(1, tile.length())
				area.very_foreground_tiles.append(tile)
			for tile in area_result.foreground_tiles:
				tile = tile.substr(1, tile.length())
				area.foreground_tiles.append(tile)
			for tile in area_result.background_tiles:
				tile = tile.substr(1, tile.length())
				area.background_tiles.append(tile)
					
			for object_result in area_result.objects:
				var object = {}
				object.properties = []
				for key in object_result.properties:
					object.properties.append(value_util.get_true_value(object_result.properties[key]))
					
				object.type_id = 1
				if object_result.type == "Entrance": # i don't even care lol
					object.type_id = 0
				elif object_result.type == "Coin":
					object.type_id = 1
				elif object_result.type == "Shine":
					object.type_id = 2
				elif object_result.type == "MetalPlatform":
					object.type_id = 3
				area.objects.append(object)
				
			new_result.areas.append(area)
	return new_result

static func convert_040_to_041(result):
	result.format_version = "0.4.1"
	for area_result in result.areas:
		if typeof(area_result) == TYPE_DICTIONARY:
			var new_objects = []
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
