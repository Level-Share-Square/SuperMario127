class_name LevelEditor

var editing := false
var area: LevelArea

func clear():
	pass

func set_level_area(area: LevelArea):
	self.area = area

func set_tile(tileset_id, tile_id):
	pass

func create_object(object: LevelObject):
	pass

func delete_object(object: LevelObject):
	pass
