class_name ChangeAreaAction
extends Action

var shared: LevelShared
var property: String
var id: int

var new_value
var old_value

func change_property(value, set_old_value: bool = true) -> void:
	var area_header = CurrentLevelData.area_headers[id]
	if set_old_value:
		old_value = area_header[property]
	area_header[property] = value
	
	if id == CurrentLevelData.area_id:
		CurrentLevelData.current_area.header[property] = value
		if property == "tile_with_edges":
			shared.update_tilemaps()
	
func _do():
	change_property(new_value)
	
func _undo():
	change_property(old_value, false)
