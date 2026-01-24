extends Node

var layers: Array

func add_layer(layer: LevelLayer):
	layers.append(layer)
	
func remove_layer(index: int):
	if(index >= layers.size()):
		push_error("tried to delete OOB layer")
	layers.remove(index)

func add_item(item: GameObject, index: int):
	if(index >= layers.size()):
		push_error("tried to delete OOB layer")

func add_tile(tile: TileData, index: int):
	if(index >= layers.size()):
		push_error("tried to delete OOB layer")

func remove_item(item: GameObject, index: int):
	if(index >= layers.size()):
		push_error("tried to delete OOB layer")

func remove_tile(tile: TileData, index: int):
	if(index >= layers.size()):
		push_error("tried to delete OOB layer")
