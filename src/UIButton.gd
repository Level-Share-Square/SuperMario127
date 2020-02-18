extends TextureButton


export var tile:int = 2
export var tile_rect:Rect2 = Rect2(96, 0, 32, 32)

func _pressed():
	var tileset = get_node("../../../TileMap")
	tileset.selected_tile = tile
	tileset.selected_tile_rect = tile_rect
