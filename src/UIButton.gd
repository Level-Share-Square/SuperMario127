extends TextureButton

class_name TileButton

export var is_tile = true
export var tileset_id := 1
export var tile_id := 0
export var object_type : String
export var tile_rect:Rect2 = Rect2(96, 0, 32, 32)

func _pressed():
	var global_vars = get_node("../../../GlobalVars")
	global_vars.is_tile = is_tile
	global_vars.selected_tileset_id = tileset_id
	global_vars.selected_tile_id = tile_id
	global_vars.selected_object_type = object_type
