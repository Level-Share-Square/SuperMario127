class_name LevelCodeSerializer



static func deserialize_level_code(code: String) -> LevelData:
	var level_code = LevelCodeTokenizer.splice_level(code)
	var metadata_code = LevelCodeTokenizer.splice_metadata(code)
	var level_components_code = LevelCodeTokenizer.splice_level_components(level_code)
	
	# all area codes (in one string)
	var area_list_code = level_components_code[0]
	var mission_data_code = level_components_code[1]
	var editor_data_code = level_components_code[2]
	
	# all area codes(in a string array)
	var areas_code = LevelCodeTokenizer.splice_areas(area_list_code)

	
	var new_level_metadata = deserialize_level_metadata_code(metadata_code)
	var new_current_area = deserialize_area_code(areas_code[0])
	var new_area_metadatas = []
	for metadata in areas_code:
		new_area_metadatas.push_back(deserialize_area_metadata_code(metadata))
	var new_mission_metadata = MissionMetadata.new()
	var new_saved_editor_data = SavedEditorData.new()
	
	var level_data = LevelData.new(new_level_metadata, new_mission_metadata, new_saved_editor_data, new_current_area, new_area_metadatas)
	return level_data
	
	
static func deserialize_area_code(area_code: String) -> AreaData:
	var area_components_code = LevelCodeTokenizer.splice_area_components(area_code)
	
	var layers_code = area_components_code[0]
	
	var area_metadata = deserialize_area_metadata_code(area_code)
	var layers = deserialize_layers_code(layers_code)
		
	return AreaData.new(area_metadata, layers)
	
	
static func deserialize_layers_code(layers_code: String) -> Array:
	var layers_code_array = LevelCodeTokenizer.splice_layers(layers_code)
	var layers = []
	for layer in layers_code_array:
		layers.push_back(deserialize_layer_code(layer))
	return layers
	
	
static func deserialize_layer_code(layer_code: String) -> LayerData:
	var layer_metadata_code = LevelCodeTokenizer.splice_metadata(layer_code)
	var layer_components = LevelCodeTokenizer.splice_layer_components(layer_code)
	var tiles_code = layer_components[1]
	var objects_code = layer_components[0]
	
	var layer_metadata = deserialize_layer_metadata_code(layer_metadata_code)
	var tiles = deserialize_tiles_code(tiles_code)
	var objects = deserialize_objects_code(objects_code)
	
	return LayerData.new(layer_metadata, objects, tiles)
	
	
static func deserialize_tiles_code(tiles_code: String) -> Array:
	var tiles_code_array = LevelCodeTokenizer.splice_tiles(tiles_code)
	var tiles = []
	for tile in tiles_code_array:
		tiles.push_back(deserialize_tile_code(tile))
		
	return tiles
	
	
static func deserialize_tile_code(tile_code: String) -> TileData:
	var data = deserialize_datas_code(tile_code)
	
	var tileset_id = data[0]
	var tile_type = data[1]
	var palette = data[2]
	var pos = data[3]
	
	return TileData.new(tileset_id, tile_type, palette, pos)
	
	
static func deserialize_objects_code(objects_code: String) -> Array:
	var objects_code_array = LevelCodeTokenizer.splice_objects(objects_code)
	var objects = []
	for object in objects_code_array:
		objects.push_back(deserialize_object_code(object))
	
	return objects
	
	
static func deserialize_object_code(object_code: String) -> ObjectData:
	var object_metadata_code = LevelCodeTokenizer.splice_metadata(object_code)
	var object_var_code = LevelCodeTokenizer.splice_object(object_code)
	
	var object_metadata = deserialize_object_metadata_code(object_metadata_code)
	var object_vars = deserialize_datas_code(object_var_code)
	
	return ObjectData.new(object_metadata, object_vars)
	
	
static func deserialize_level_metadata_code(level_metadata_code: String) -> LevelMetadata:
	var vars = deserialize_datas_code(level_metadata_code)
	
	var level_name = vars[0]
	var level_author = vars[1]
	var level_description = vars[2]
	var level_thumbnail_url = vars[3]
	
	return LevelMetadata.new(level_name, level_author, level_description, level_thumbnail_url)
	
	
# !! Takes full area code as input! so that the area code can be stored as a variable
static func deserialize_area_metadata_code(area_code: String) -> AreaMetadata:
	var area_metadata_code = LevelCodeTokenizer.splice_metadata(area_code)
	var vars = deserialize_datas_code(area_metadata_code)
	
	var bounds: Rect2 = vars[0]
	var name: String = vars[1]
	var sky: int = vars[2]
	var background: int = vars[3]
	var background_palette: int = vars[4]
	var bg_autoscroll_speed: float = vars[5]
	var gravity: float = vars[6]
	var timer: float = vars[7]
	var music = vars[8]
	var underwater_music: String = vars[9]

	return AreaMetadata.new(area_code, bounds, name, sky, background, background_palette, bg_autoscroll_speed, gravity, timer, music, underwater_music)
	
	
static func deserialize_layer_metadata_code(layer_metadata_code: String) -> LayerMetadata:
	var vars = deserialize_datas_code(layer_metadata_code)
	
	var parallax_distance: int = vars[0]
	var autoset_tint: bool = vars[1]
	var layer_tint: Color = vars[2]
	var order: int = vars[3]
	var is_ground: bool = vars[4]
	var activated_mission_id: int = vars[5]
	
	return LayerMetadata.new(parallax_distance, autoset_tint, layer_tint, order, is_ground, activated_mission_id)
	
	
static func deserialize_object_metadata_code(object_metadata_code: String) -> ObjectMetadata:
	var vars = deserialize_datas_code(object_metadata_code)
	
	var type_id: int = vars[0]
	var palette: int = vars[1]
	var enabled: bool = vars[2]
	var rotation: int = vars[3]
	
	return ObjectMetadata.new(type_id, palette, enabled, rotation)
	
# basically, this is the finest grain part of the level code; we are just looking at primitive values
# pass in a list of primitive values to this function and it will interpret them
static func deserialize_datas_code(datas_code: String) -> Array:
	var vars_code = LevelCodeTokenizer.splice_data(datas_code)
	var vars = []
	for v in vars_code:
		vars.push_back(deserialize_data_code(v))
		
	return vars
	
	
static func deserialize_data_code(data_code: String):
	var code = data_code.substr(0, 1)
	var data = data_code.substr(1)
	var result
	
	match code:
		#string
		"S":
			result = data
		#Int
		"I":
			result = int(data)
		#Bool
		"B":
			result = bool(data)
		#Float
		"F":
			result = float(data)
		#vector
		"V":
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			result = Vector2(data_array[0], data_array[1])
		# Color
		"C":
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			if(data_array.size() > 3):
				result = Color(data_array[0], data_array[1], data_array[2], data_array[3])
			else:
				result = Color(data_array[0], data_array[1], data_array[2], 255)
		# PoolStringArray
		"T":
			data = LevelCodeTokenizer.splice_data_array(data)
			result = PoolStringArray(deserialize_datas_code(data))
		# PoolVector2Array
		"E":
			data = LevelCodeTokenizer.splice_data_array(data)
			result = PoolVector2Array(deserialize_datas_code(data))
		 # Rect2
		"R":
			data = LevelCodeTokenizer.splice_data_array(data)
			var data_array = deserialize_datas_code(data)
			result = Rect2(data_array[0], data_array[1], data_array[2], data_array[3])
		# Still need to do curve2d but idk how that one works really
		
	return result
