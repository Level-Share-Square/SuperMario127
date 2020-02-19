extends TextureButton

class_name TileButton


export var tile:int = 2
export var tile_rect:Rect2 = Rect2(96, 0, 32, 32)

func _pressed():
	var global_vars = get_node("../../../GlobalVars")
	global_vars.selected_tile = tile
	global_vars.selected_tile_rect = tile_rect
