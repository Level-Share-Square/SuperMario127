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

func move_area(src_id: int, delta: int):
	# A positive delta means to move the area down.
	# A negative delta moves it up. (This aligns with the data better)
	var dest_id = src_id + delta
	var max_id = CurrentLevelData.area_headers.size() - 1
	if dest_id > max_id or dest_id < 0:
		return

	# Shift area headers
	var area_data = CurrentLevelData.area_headers.pop_at(src_id)
	CurrentLevelData.area_headers.insert(dest_id, area_data)

	# This silly thing gives us an id transformation array.
	var id_map = range(0, max_id + 1)
	var tmp = id_map.pop_at(src_id)
	id_map.insert(dest_id, tmp)
	
	# Properly re-assign the current area_id.
	CurrentLevelData.area_id = id_map.find(CurrentLevelData.area_id)
	
	# Shift area cache
	var cache_copy = CurrentLevelData.loaded_areas.duplicate()
	CurrentLevelData.loaded_areas.clear()
	for new_id in range(0, max_id + 1):
		var old_id = id_map[new_id]
		if cache_copy.has(old_id):
			CurrentLevelData.loaded_areas[new_id] = cache_copy[old_id]
