class_name LevelLayer
extends Node2D


func load_in(layer_data: LayerData):
	pass


# Tiles
func place_tile(coords, tile_set, tile, palette):
	pass


func erase_tile(to_remove: Vector2):
	pass


# Objects
func add_object(to_add: ObjectData):
	pass


func place_object(s_position: Vector2, to_place: ObjectData):
	pass


func erase_object(to_remove: GameObject):
	pass


