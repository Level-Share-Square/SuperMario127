extends Resource

class_name LevelArea

var objects = []
var background_tiles := []
var foreground_tiles := []
var very_foreground_tiles := []
var settings: LevelAreaSettings

func get_true_value(value):
	if typeof(value) == TYPE_DICTIONARY:
		# very hacky cause i dont know how else to add it
		if value.type == "Vector2":
			return Vector2(value.construction[0], value.construction[1])
	else:
		return value
		
func get_value_from_true(value):
	# again very hacky cause i dont know how else to add it
	if typeof(value) == TYPE_VECTOR2:
		return {type="Vector2", construction=[value.x, value.y]}
	else:
		return value

func load_object(object: LevelObject):
	var object_class = load("res://src/objects/" + object.type + ".gd")
	var node = object_class.new()
	for key in object.properties:
		var value = object.properties[key]
		var true_value = get_true_value(value)
		node[key] = true_value
	return node

func load_editor_object(object: LevelObject):
	var object_class = load("res://src/editor_objects/" + object.type + ".gd")
	var node = object_class.new()
	node.level_object = object
	for key in object.properties:
		var value = object.properties[key]
		var true_value = get_true_value(value)
		node[key] = true_value
	return node

func get_position_from_tile_index(index: int) -> Vector2:
	return Vector2(
		index - (floor(index / settings.size.x) * settings.size.x),
		floor(index / settings.size.x)
	)

func get_tile_index_from_position(position: Vector2) -> int:
	return int(floor((settings.size.x * position.y) + position.x))

func load_in(node: Node, isEditing: bool):
	var character = node.get_node("../Character")
	var level_objects = node.get_node("../LevelObjects")
	var background_tile_map = node.get_node("../BackgroundTileMap")
	var tile_map = node.get_node("../TileMap")
	var very_foreground_tile_map = node.get_node("../VeryForegroundTileMap")
	var global_vars = node.get_node("../GlobalVars")
	
	for index in range(very_foreground_tiles.size()):
		var tile = very_foreground_tiles[index]
		var position = get_position_from_tile_index(index)
		very_foreground_tile_map.set_cell(position.x, position.y, global_vars.get_tile(tile[0], tile[1]))
		
	for index in range(foreground_tiles.size()):
		var tile = foreground_tiles[index]
		var position = get_position_from_tile_index(index)
		tile_map.set_cell(position.x, position.y, global_vars.get_tile(tile[0], tile[1]))
		
	for index in range(background_tiles.size()):
		var tile = background_tiles[index]
		var position = get_position_from_tile_index(index)
		background_tile_map.set_cell(position.x, position.y, global_vars.get_tile(tile[0], tile[1]))
		
	very_foreground_tile_map.update_bitmask_region(Vector2(0, 0), Vector2(settings.size.x, settings.size.y))
	tile_map.update_bitmask_region(Vector2(0, 0), Vector2(settings.size.x, settings.size.y))
	background_tile_map.update_bitmask_region(Vector2(0, 0), Vector2(settings.size.x, settings.size.y))
		
	character.position = settings.spawn
	if !isEditing:
		for object in objects:
			var node_object = load_object(object)
			level_objects.add_child(node_object)
	else:
		for object in objects:
			var node_object = load_editor_object(object)
			level_objects.add_child(node_object)
			
func save_out(node: Node, isEditing: bool):
	var background_tile_map = node.get_node("../BackgroundTileMap")
	var tile_map = node.get_node("../TileMap")
	var very_foreground_tile_map = node.get_node("../VeryForegroundTileMap")
	var global_vars = node.get_node("../GlobalVars")
	var level_objects = node.get_node("../LevelObjects")
	
	var level_size = Vector2(80, 30)
	var spawn_location = Vector2(0, 0)
	
	var saved_json = File.new()
	var level_dictionary = {}
	level_dictionary.format_version = "0.3.2"
	level_dictionary.name = "My Level"
	level_dictionary.areas = [{}]
	level_dictionary.areas[0].background_tiles = []
	level_dictionary.areas[0].foreground_tiles = []
	level_dictionary.areas[0].very_foreground_tiles = []
	level_dictionary.areas[0].objects = []
	level_dictionary.areas[0].settings = {}
	level_dictionary.areas[0].settings.background = "1"
	level_dictionary.areas[0].settings.music = "1"
	level_dictionary.areas[0].settings.size = {x = level_size.x, y = level_size.y}
	level_dictionary.areas[0].settings.spawn = {x = spawn_location.x, y = spawn_location.y}
	
	for index in range(settings.size.x * settings.size.y):
		var position = get_position_from_tile_index(index)
		var tile = tile_map.get_cell(position.x, position.y)
		var encoded_tile = global_vars.get_tile_from_godot_id(tile)
		var appended_tile = encoded_tile[0] + encoded_tile[1]
		level_dictionary.areas[0].foreground_tiles.append(appended_tile)
		
		var tile_background = background_tile_map.get_cell(position.x, position.y)
		var encoded_tile_background = global_vars.get_tile_from_godot_id(tile_background)
		var appended_tile_background = encoded_tile_background[0] + encoded_tile_background[1]
		level_dictionary.areas[0].background_tiles.append(appended_tile_background)
		
		var tile_very_foreground = very_foreground_tile_map.get_cell(position.x, position.y)
		var encoded_tile_very_foreground = global_vars.get_tile_from_godot_id(tile_very_foreground)
		var appended_tile_very_foreground = encoded_tile_very_foreground[0] + encoded_tile_very_foreground[1]
		level_dictionary.areas[0].very_foreground_tiles.append(appended_tile_very_foreground)
	level_dictionary.areas[0].background_tiles = rle_encode(level_dictionary.areas[0].background_tiles)
	level_dictionary.areas[0].foreground_tiles = rle_encode(level_dictionary.areas[0].foreground_tiles)
	level_dictionary.areas[0].very_foreground_tiles = rle_encode(level_dictionary.areas[0].very_foreground_tiles)
	
	for index in objects:
		var added_object = {}
		added_object.type = index.type
		added_object.properties = {}
		for property in index.properties:
			added_object.properties[property] = get_value_from_true(index.properties[property])
		level_dictionary.areas[0].objects.append(added_object)
	
	var exportstr = JSON.print(level_dictionary)
	if OS.has_feature("JavaScript"):
		JavaScript.eval("""
			const el = document.createElement('textarea')
			el.value = '""" + exportstr + """'
			document.body.appendChild(el)
			el.select()
			document.execCommand('copy')
			document.body.removeChild(el)
		""", true)
	else:
		OS.clipboard = exportstr

func unload(node: Node):
	var level_objects = node.get_node("../LevelObjects")
	var background_tile_map = node.get_node("../BackgroundTileMap")
	var tile_map = node.get_node("../TileMap")
	var very_foreground_tile_map = node.get_node("../VeryForegroundTileMap")
	for object in level_objects.get_children():
		object.queue_free()
	for x in range(settings.size.x):
		for y in range(settings.size.y):
			background_tile_map.set_cell(x, y, -1)
			tile_map.set_cell(x, y, -1)
			very_foreground_tile_map.set_cell(x, y, -1)

func rle_encode(data):
	var new_data = []
	var last_index = ""
	var count = 1
	
	for index in data:
		if index != last_index:
			if last_index:
				var append_string = "*" + str(count)
				if count == 1:
					append_string = ""
				new_data.append(last_index + append_string)
			count = 1
			last_index = index
		else:
			count += 1
			
	var append_string_last = "*" + str(count)
	if count == 1:
		append_string_last = ""
	new_data.append(last_index + append_string_last)
	
	return new_data
