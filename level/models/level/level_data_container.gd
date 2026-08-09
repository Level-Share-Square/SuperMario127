class_name LevelDataContainer
extends LevelDataResource


var level_metadata: LevelMetadata
var editor_data: EditorData
var area_headers: Array
var level_tags: LevelTags


func _init(set_level: LevelMetadata, set_editor_data: EditorData, set_area_headers: Array, set_level_tags: LevelTags):
	level_metadata = set_level
	editor_data = set_editor_data
	area_headers = set_area_headers
	level_tags = set_level_tags
