class_name LevelDataContainer
extends LevelDataResource


var level_metadata: LevelMetadata
var editor_data: EditorData
var mission_data: Array
var area_headers: Array


func _init(set_level: LevelMetadata, set_editor_data: EditorData, set_mission: Array, set_area_headers: Array):
	level_metadata = set_level
	mission_data = set_mission
	editor_data = set_editor_data
	area_headers = set_area_headers
