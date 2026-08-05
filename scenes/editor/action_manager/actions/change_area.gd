class_name ChangeAreaAction
extends Action

var property: String
var id: int

var new_value
var old_value

func change_property(value) -> void:
	var area_header = CurrentLevelData.area_headers[id]
	old_value = area_header[property]
	area_header[property] = value
	
	if id == CurrentLevelData.area_id:
		CurrentLevelData.current_area.header[property] = value
	
func _do():
	change_property(new_value)
	
func _undo():
	change_property(old_value)
