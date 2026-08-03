class_name LevelCodeHandler
extends Reference


const RED_COIN_ID: int = 30
const SHINE_SHARD_ID: int = 45
const PURPLE_COIN_ID: int = 135

const ENABLED_PROP_ID: int = 3


static func recalculate_level_collectible_counts(level_data_container) -> void:
	var level_metadata = level_data_container.level_metadata
	var area_headers = level_data_container.area_headers
	
	level_metadata.collectible_data.red_coin_count = 0
	
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
				
				if object.metadata.type_id == RED_COIN_ID and object.get_property(ENABLED_PROP_ID) == null:
					level_metadata.collectible_data.red_coin_count += 1
				
				if object.metadata.type_id == SHINE_SHARD_ID and object.get_property(ENABLED_PROP_ID) == null:
					area.header.shine_shard_count += 1
				
				if object.metadata.type_id == PURPLE_COIN_ID and object.get_property(ENABLED_PROP_ID) == null:
					area.header.max_purples_count += 1
					

		area.header.area_code = LevelCodeSerializer.serialize_area(area)
		area_headers[i] = area.header
