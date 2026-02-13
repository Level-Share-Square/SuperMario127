extends Node


var player: LevelPlayer


# The purpose of this script is to take the new level data format, and instance all of the data into an actual level by setting variables which are scattered across multiple scenes and scripts

func _init(_player: LevelPlayer):
	player = _player

func instance_level_data(data: LevelData):
	instance_level_metadata(data.level_metadata)
	#Old functionality is that all areas are loaded at once. We should really change this later. For now im keeping it this way for simplicities sake.
	for area in data.area_metadatas:
		var area_data = LevelCodeSerializer.deserialize_area_code(area.area_code)
		instance_area(area_data)
	
func instance_level_metadata(data: LevelMetadata):
	var level_info = Singleton.CurrentLevelData.level_info
	level_info.level_name = data.level_name
	level_info.level_author = data.level_author
	level_info.level_description = data.level_description
	level_info.thumbnail_url = data.level_thumbnail_url
	level_info.thumbnail_sky = data.level_thumbnail_sky
	level_info.thumbnail_background = data.level_thumbnail_background
	level_info.thumbnail_background_palette = data.level_thumbnail_background_palette
	
func instance_area(data: AreaData):
	var area_data: LevelAreaOld = AreaDataOld.new()
	instance_area_metadata(data.area_metadata, area_data)
	instance_layers_array(data.layers, area_data)
	Singleton.CurrentLevelData.level_data.areas.append(area_data)
	
func instance_area_metadata(data: AreaMetadata, data_old: LevelAreaOld):
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

func instance_layers_array(layers: Array, data_old: LevelAreaOld):
	for layer in layers:
		var new_layer = LevelLayer.new()
		instance_layer(layer, new_layer)
		data_old.layers.append(new_layer)
		
func instance_layer(data: LayerData, layer: LevelLayer):
	instance_layer_metadata(data.layer_metadata, layer)
	instance_objects_array(data.object_datas, layer)
	instance_tiles_array(data.tile_datas, layer)
	
func instance_objects_array(object_datas: Array, layer: LevelLayer):
	for data in object_datas:
		var object = ObjectDataOld.new()
		instance_object(data, objet)
		
func instance_object(data: ObjectData, object: ObjectDataOld):
	instance_object_metadata(data.metadata, object)
	object.properties.append(data.properties)
	
func instance_object_metadata(data: ObjectMetadata, object: ObjectDataOld):
	object.type_id = data.type_id
	object.palette = data.palette
	# I don't know if this is corret because i dont know what type the properties array is suppposed to accept. literally just guessing
	object.properties.append(data.enabled)
	object.properties.append(data.rotation)
	
func instance_tiles_array(tiles: Array, layer: LevelLayer):
	var tilemap: TileMap = TileMap.new()
	for tile in tiles:
		instance_tile(tile, tilemap)
	# add tilemap to layer
	
func instance_tile(tile: TileData, tilemap: TileMap):
	pass
	
	
func instance_layer_metadata(data: LayerMetadata, layer: LevelLayer):
	pass
