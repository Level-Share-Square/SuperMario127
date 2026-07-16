class_name LevelResourceTool


static func unpack_level_data(level_data: LevelDataOld):
	pass

static func set_level_vars(level_metadata: LevelMetadata):
	CurrentLevelData.vars.name = level_metadata.level_name
	CurrentLevelData.vars.author = level_metadata.level_author
	CurrentLevelData.vars.description = level_metadata.level_description
	CurrentLevelData.vars.thumbnail_url = level_metadata.level_thumbnail_url
	

	
