class_name LevelData
extends Resource


var mission_metadata: MissionMetadata
var level_metadata: LevelMetadata
var saved_editor_data: SavedEditorData

var current_area: AreaData
var area_metadatas: Array


func _init(set_level: LevelMetadata, set_mission: MissionMetadata, set_saved_editor: SavedEditorData, set_current_area: AreaData, set_area_metadatas: Array):
	level_metadata = set_level
	mission_metadata = set_mission
	saved_editor_data = set_saved_editor
	current_area = set_current_area
	area_metadatas = set_area_metadatas


func serialize() -> String:
	var level_metadata_serialized = level_metadata.serialize()
	var mission_metadata_serialized = mission_metadata.serialize()
	var saved_editor_data_serialized = saved_editor_data.serialize()
	var areas_serialized = ""
	for area in area_metadatas:
		areas_serialized += area.area_code
	return level_metadata_serialized + mission_metadata_serialized + saved_editor_data_serialized + areas_serialized
	
	
static func deserialize(level_code: String) -> LevelData:
	var new_level_metadata = LevelMetadata.deserialize(delimit_level_metadata(level_code))
	var new_mission_metadata = MissionMetadata.deserialize(delimit_mission_metadata(level_code))
	var new_saved_editor_data = SavedEditorData.deserialize(delimit_saved_editor_data(level_code))
	
	var new_area_metadatas = []
	var area_metadata_strings = delimit_area_metadatas(level_code)
	for metadata in area_metadata_strings:
		new_area_metadatas.append(AreaMetadata.deserialize(metadata))
	
	var current_area_code = ""
	for metadata in new_area_metadatas:
		if(metadata.area_id == new_saved_editor_data.area_id):
			current_area_code = metadata.area_code
			break
	var new_current_area = AreaData.deserialize(current_area_code)
		
	return LevelData.new(new_level_metadata, new_mission_metadata, new_saved_editor_data, new_current_area, new_area_metadatas)
	
	
static func delimit_level_metadata(level_code: String) -> String:
	return ""
	
	
static func delimit_mission_metadata(level_code: String) -> String:
	return ""
	

static func delimit_saved_editor_data(level_code: String) -> String:
	return ""
	
	
static func delimit_area_metadatas(level_code: String) -> String:
	return ""

static func delimit_areas(level_code: String) -> Array:
	return []
