class_name ResizeAreaAction
extends Action


var shared: LevelShared

var area_settings: LevelAreaOldSettings = CurrentLevelData.level_data.areas[CurrentLevelData.area].area_settings
var bounds: Rect2


func _do() -> void:
	area_settings = CurrentLevelData.level_data.areas[CurrentLevelData.area].area_settings
	last_bounds = area_settings.bounds
	area_settings.bounds = bounds
	

var last_bounds: Rect2
func _undo() -> void:
	area_settings.bounds = last_bounds
