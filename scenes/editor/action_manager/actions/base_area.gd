extends Action
class_name BaseAreaAction

var area_header
var area_id: int = -1

func create_area():
	area_id = area_id if area_id != -1 else CurrentLevelData.area_headers.size()
	if area_id <= CurrentLevelData.area_id:
		CurrentLevelData.area_id += 1
	CurrentLevelData.area_headers.insert(area_id, area_header)
	
func delete_area():
	if area_id == -1:
		area_id = CurrentLevelData.area_headers.find(area_header)
		CurrentLevelData.area_headers.erase(area_header)
	else:
		area_header = CurrentLevelData.area_headers[area_id]
		CurrentLevelData.area_headers.remove(area_id)

	if CurrentLevelData.loaded_areas.get(area_id):
		CurrentLevelData.unload_level_area(area_id)
