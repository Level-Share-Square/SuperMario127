class_name LevelEditor

var editing := false
var area: LevelArea

func load_in(node: Node):
	area.load_in(node, true)
	
func save_out(node: Node):
	area.save_out(node, true)
	
func unload(node: Node):
	area.unload(node)

func clear():
	pass

func set_level_area(area: LevelArea):
	self.area = area

func set_tile(position: Vector2, tileset_id, tile_id, layer):
	var tiles_array = area.foreground_tiles
	if layer == 0:
		tiles_array = area.background_tiles
	elif layer == 2:
		tiles_array = area.very_foreground_tiles
		
	var index = area.get_tile_index_from_position(position)
	if index + 1 >= tiles_array.size():
		for newIndex in range(tiles_array.size(), index + 1):
			tiles_array.append([0, 0])
	var size = area.settings.size
	if position.x > size.x || position.y > size.y:
		area.settings.size = position
	tiles_array[index] = [tileset_id, tile_id]
	
func get_object_at_position(node: Node, position: Vector2):
	var level_objects = node.get_node("../LevelObjects")
	for object in level_objects.get_children():
		if object.position == position:
			return object

func create_object(node: Node, id: int, name:String, properties: Dictionary):
	var level_objects = node.get_node("../LevelObjects")
	if !get_object_at_position(node, properties.position):
		var level_object = LevelObject.new()
		level_object.id = id
		level_object.name = name
		level_object.properties = properties
		area.objects.append(level_object)
		var node_object = area.load_editor_object(level_object)
		level_objects.add_child(node_object)

func delete_object_at_position(node: Node, position: Vector2):
	var object_node = get_object_at_position(node, position)
	if object_node:
		delete_object(object_node)
		
func delete_object(object_node: Node):
	area.objects.erase(object_node.level_object)
	object_node.queue_free()
