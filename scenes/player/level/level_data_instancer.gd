extends Node


var player: LevelPlayer


# The purpose of this script is to take the new level data format, and instance all of the data into an actual level by setting variables which are scattered across multiple scenes and scripts

func _init(_player: LevelPlayer):
	player = _player

func instance_level_data(data: LevelData):
	instance_level_metadata(data.level_metadata)
	instance_area(data.current_area)
	
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
	instance_area_metadata(data.area_metadata)
	
func instance_area_metadata(data: AreaMetadata):
	var background_node = get_node(player.backgrounds)
	background_node.update_background(data.sky, data.background, data.bounds, 0, data.background_palette, data.bg_autoscroll_speed)
	
