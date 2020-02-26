class_name LevelEditor

var editing := false
var area: LevelArea

func load_in(node: Node):
	area.load_in(node, true)

func clear():
	pass

func set_level_area(area: LevelArea):
	self.area = area

func set_tile(position: Vector2, tileset_id, tile_id):
	var index = area.get_tile_index_from_position(position)
	if index + 1 >= area.foreground_tiles.size():
		for newIndex in range(area.foreground_tiles.size(), index + 1):
			area.foreground_tiles.append([0, 0])
	var size = area.settings.size
	if position.x > size.x || position.y > size.y:
		area.settings.size = position
	area.foreground_tiles[index] = [tileset_id, tile_id]

func create_object(object: LevelObject):
	pass

func delete_object(object: LevelObject):
	pass
