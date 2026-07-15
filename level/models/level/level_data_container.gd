class_name LevelDataContainer
extends LevelDataResource


var level_metadata: LevelMetadata
var saved_editor_data: SavedEditorData
var mission_data: Array
var area_headers: Array


func _init(set_level: LevelMetadata, set_saved_editor: SavedEditorData, set_mission: Array, set_area_headers: Array):
	level_metadata = set_level
	mission_data = set_mission
	saved_editor_data = set_saved_editor
	area_headers = set_area_headers
