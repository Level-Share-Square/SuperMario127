class_name LevelGroundLayer
extends LevelLayer


func load_in(layer_data: LayerData) -> void:
	.load_in(layer_data)
	
	tile_map_manager.load_in(layer_data)
	object_manager.load_in(layer_data)
	
#	_test_load_in(layer_data)


# used for testing load times
func _test_load_in(layer_data: LayerData) -> void:
	# tile loading
	var times: PoolIntArray
	for i in range(50):
		var ticks_start: int = Time.get_ticks_usec()
		tile_map_manager.load_in(layer_data)
		times.append(Time.get_ticks_usec() - ticks_start)

	var high: float = 0
	var average: float = 0
	for time in times:
		average += time
		if high < time:
			high = time

	average /= float(times.size())
	print("Highest time to load tiles: ", high / 1000000.0)
	print("Average time to load tiles: ", average / 1000000.0)
	print("All time data (in microseconds): ", times)

	# object loading 
	# (not very useful as it seems to deteriorate over time when done like this)
	times.clear()
	for i in range(8):
		var ticks_start: int = Time.get_ticks_usec()
		object_manager.load_in(layer_data)
		times.append(Time.get_ticks_usec() - ticks_start)

	high = 0
	average = 0
	for time in times:
		average += time
		if high < time:
			high = time

	average /= float(times.size())
	print("Highest time to load objects: ", high / 1000000.0)
	print("Average time to load objects: ", average / 1000000.0)
	print("All time data (in microseconds): ", times)

	assert(false)


# tiles
func place_tile(coords, tile_set, tile, palette, update_autotile, modify_data):
	tile_map_manager.place_tile(coords, tile_set, tile, palette, update_autotile, modify_data)


func erase_tile(to_remove: Vector2):
	tile_map_manager.erase_tile(to_remove)


# objects
func add_object(to_add: ObjectData, modify_data: bool = false):
	return object_manager.place_object(to_add, modify_data)


func place_object(to_place: ObjectData, modify_data: bool = false):
	return object_manager.place_object(to_place, modify_data)


func erase_object(to_remove):
	object_manager.erase_object(to_remove)


