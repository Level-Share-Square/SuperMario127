class_name LevelGroundLayer
extends LevelLayer

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
