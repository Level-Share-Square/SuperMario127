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
