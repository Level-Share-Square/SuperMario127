class_name LevelResourceTool


static func unpack_level_data(level_data: LevelData):
	pass

static func set_level_vars(level_metadata: LevelMetadata):
	Singleton.CurrentLevelData.level_data.vars.name = level_metadata.level_name
	Singleton.CurrentLevelData.level_data.vars.author = level_metadata.level_author
	Singleton.CurrentLevelData.level_data.vars.description = level_metadata.level_description
	Singleton.CurrentLevelData.level_data.vars.thumbnail_url = level_metadata.level_thumbnail_url
	

	
