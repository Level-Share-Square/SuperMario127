class_name LevelDataInstancer
extends Node


const LAYER_SCENE = preload("res://scenes/shared/level_layer/level_layer.tscn")


# The purpose of this script is to take the new level data format, and instance all of the data into an actual level by setting variables which are scattered across multiple scenes and scripts


func instance_level_data(data: LevelDataOld):
	instance_level_metadata(data.level_metadata)
	#Old functionality is that all areas are loaded at once. We should really change this later. For now im keeping it this way for simplicities sake.
	for area in data.area_metadatas:
		var area_data = LevelCodeDeserializer.deserialize_area_code(area.area_code)
		instance_area(area_data)


func instance_level_metadata(data: LevelMetadata):
	if(CurrentLevelData.level_info == null):
		#this is a conflict with the old loading logic, im not sure how to get around it...
		var level_id: String = CurrentLevelData.level_id
		var working_folder: String = CurrentLevelData.working_folder
		var is_campaign: bool = CurrentLevelData.is_campaign
		
		var code_path: String = level_list_util.get_level_file_path(level_id, working_folder)
		var level_code: String = level_list_util.load_level_code_file(code_path)
		
		CurrentLevelData.level_info = LevelInfo.new(level_id, working_folder, level_code)
	
	var level_info = CurrentLevelData.level_info
	level_info.level_name = data.level_name
	level_info.level_author = data.level_author
	level_info.level_description = data.level_description
	level_info.thumbnail_url = data.level_thumbnail_url
	level_info.thumbnail_sky = data.level_thumbnail_sky
	level_info.thumbnail_background = data.level_thumbnail_background
	level_info.thumbnail_background_palette = data.level_thumbnail_background_palette


func instance_area(data: AreaData):
	var area_data: AreaDataOld = AreaDataOld.new()
	instance_area_metadata(data.area_metadata, area_data)
	instance_layers_array(data.layers, area_data)
	CurrentLevelData.level_data.areas.append(area_data)


func instance_area_metadata(data: AreaHeader, data_old: AreaDataOld):
	data_old.bounds = data.bounds
	data_old.sky = data.sky
	data_old.background = data.background
	data_old.background_palette = data.background_palette
	data_old.bg_autoscroll_speed = data.bg_autoscroll_speed
	data_old.gravity = data.gravity
	data_old.timer = data.timer
	data_old.name = data.name
	data_old.music = data.music
	data_old.underwater_music = data.underwater_music


func instance_layers_array(layers: Array, data_old: AreaDataOld):
	for layer in layers:
		var new_layer = LAYER_SCENE.instance()
		add_child(new_layer)
		instance_layer(layer, new_layer)
		data_old.layers.append(new_layer)


func instance_layer(data: LayerData, layer: LevelLayer):
	instance_layer_metadata(data.layer_metadata, layer)
	instance_objects_array(data.object_datas, layer)
	instance_tiles_array(data.tile_datas, layer)


func instance_objects_array(object_datas: Array, layer: LevelLayer):
	for data in object_datas:
		instance_object(data, layer)


func instance_object(data: ObjectData, layer: LevelLayer):
	var object = ObjectDataOld.new()
	instance_object_metadata(data.metadata, object)
	object.properties.append(data.properties)
	var shared = LevelShared
	layer.place_object(shared.create_object(object, true))
	
func instance_object_metadata(data: ObjectMetadata, object: ObjectDataOld):
	object.type_id = data.type_id
	object.palette = data.palette
	# I don't know if this is corret because i dont know what type the properties array is suppposed to accept. literally just guessing
	object.properties.append(data.enabled)
	object.properties.append(data.rotation)
	


func instance_tiles_array(tiles: Array, layer: LevelLayer):
	for tile in tiles:
		instance_tile(tile, layer)


func instance_tile(tile: TileData, layer: LevelLayer):
	pass
#	layer.place_tile(tile)


func instance_layer_metadata(data: LayerMetadata, layer: LevelLayer):
	layer.set_parallax_distance(data.parallax_distance)
	layer.set_autoset_tint(data.autoset_tint)
	layer.set_layer_tint(data.layer_tint)
	layer.set_order(data.order)
	layer.set_is_ground(data.is_ground)
	layer.set_activated_mission_id(data.activated_mission_id)
