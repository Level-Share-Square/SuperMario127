extends TextureButton

class_name TileButton


export var tileset:int = 1
export var tile:int = 0
export var tile_rect:Rect2 = Rect2(96, 0, 32, 32)

func _pressed():
	var global_vars = get_node("../../../GlobalVars")
	global_vars.selected_tileset_id = tileset
	global_vars.selected_tile_id = tile
	global_vars.selected_tile_rect = tile_rect
