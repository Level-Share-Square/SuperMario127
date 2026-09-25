class_name LevelCodeHandler
extends Reference


const RED_COIN_ID: int = 30
const SHINE_SHARD_ID: int = 45
const PURPLE_COIN_ID: int = 135
const SHINE_ID: int = 2
const STAR_COIN_ID: int = 52

const ENABLED_PROP_ID: int = 2


static func recalculate_level_collectible_counts(level_data_container) -> void:
	var level_metadata = level_data_container.level_metadata
	var area_headers = level_data_container.area_headers
	var used_mission_data = level_metadata.collectible_data.used_mission_data
	var star_coin_data = level_metadata.collectible_data.star_coin_data
	
	level_metadata.collectible_data.red_coin_count = 0
	used_mission_data.clear()
	var final_star_coin_data: Array = []
	
	var area_header: AreaHeader
	for i in range(area_headers.size()):
		var area = LevelCodeDeserializer.deserialize_area_code(area_headers[i].area_code)
		area.header = area_headers[i]
		area.header.shine_shard_count = 0
		area.header.max_purples_count = 0
		for layer in area.layers:
			if layer is LevelParallaxLayer: 
				continue
			
			for object in layer.object_data:
				object = object as ObjectData
				
				if object.metadata.type_id == RED_COIN_ID and (object.get_property(ENABLED_PROP_ID) == null or object.get_property(ENABLED_PROP_ID) == true):
					level_metadata.collectible_data.red_coin_count += 1
				
				if object.metadata.type_id == SHINE_SHARD_ID and (object.get_property(ENABLED_PROP_ID) == null or object.get_property(ENABLED_PROP_ID) == true):
					area.header.shine_shard_count += 1
				
				if object.metadata.type_id == PURPLE_COIN_ID and (object.get_property(ENABLED_PROP_ID) == null or object.get_property(ENABLED_PROP_ID) == true):
					area.header.max_purples_count += 1
					
				if object.metadata.type_id == SHINE_ID and (object.get_property(ENABLED_PROP_ID) == null or object.get_property(ENABLED_PROP_ID) == true):
					if object.properties.has(7):
						if object.properties[7]:
							if not used_mission_data.get(object.properties[7], null):
								used_mission_data[object.properties[7]] = 1
							else:
								used_mission_data[object.properties[7]] = used_mission_data[object.properties[7]] + 1
						
				if object.metadata.type_id == STAR_COIN_ID and (object.get_property(ENABLED_PROP_ID) == null or object.get_property(ENABLED_PROP_ID) == true):
					var uuid: String = object.properties[4]
					var data: StarCoinData = level_metadata.collectible_data.get_star_coin_by_uuid(uuid)
					if uuid and data and not data in final_star_coin_data: final_star_coin_data.append(data)
					else: 
						data = level_metadata.collectible_data.add_star_coin()
						object.properties[4] = data.star_coin_uuid
						data.star_coin_color = object.properties[6]
						data.star_coin_hint = object.properties[5]
						final_star_coin_data.append(data)
			

		area.header.area_code = LevelCodeSerializer.serialize_area(area)
		area_headers[i] = area.header
	
	level_metadata.collectible_data.star_coin_data = final_star_coin_data

# Can use either level code or LevelDataContainer
# No function overloading so just leave either one
# empty if needed.
static func check_and_convert_new_level(level_code: String, data_container = null):
	var current_level_version: int = ProjectSettings.get_setting("global/level_code_version")
	if not data_container:
		data_container = conversion_util.generate_data_container(level_code)
		
	var level_version: int = data_container.level_metadata.level_version
	
	if current_level_version == level_version: return {"has_converted": false, "level_code": level_code}
	
	# mandatory because .call() is not static
	var conversion_script = load("res://util/conversion_util.gd")
	
	while level_version < current_level_version:
		print("Converting level from code ", str(level_version), " to ", str(level_version + 1))
		var method: String = "convert_" + str(level_version) + "_to_" + str(level_version + 1)

		data_container = conversion_script.call(method, data_container)
			
		level_version += 1
			
	level_code = LevelCodeSerializer.serialize_level_data(data_container)
	return {"has_converted": true, "level_code": level_code, "level_data_container": data_container}
