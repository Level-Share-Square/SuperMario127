extends Node
# okay so in the player.tscn scene, there will be a node called "layers" which holdss all 
# of the level's layers. each layer holds tiles and objects. so what i want you to write 
# is classes which access that layers node to manage them, to be used by the editor
var layers: Array

func add_layer(layer: LevelLayer):
	layers.append(layer)
	
func remove_layer(index: int):
	if(index >= layers.size()):
		push_error("Tried to delete OOB layer (out of range)")
	layers.remove(index)

func add_item(item: GameObject, index: int):
	if(index >= layers.size()):
		push_error("Tried to add item to layers (out of range)")
	layers[index].place_object(item)
	
func add_tile(tile: TileData, index: int):
	if(index >= layers.size()):
		push_error("Tried to add tile to layers (out of range)")
	layers[index].place_tile(tile)
	
func remove_item(item: GameObject, index: int):
	if(index >= layers.size()):
		push_error("Tried to delete item from layers (out of range)")
	layers[index].remove_object(item) 

func remove_tile(tile: TileData, index: int):
	if(index >= layers.size()):
		push_error("Tried to delete tile from layers (out of range)")
	layers[index].remove_tile(tile)	

