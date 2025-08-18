extends Node2D

const MAX_LAYERS = 10

var layers: Array
var current_layer: LevelLayer

# Class that the editor uses to handle all placing of objects and management of level layers.
# It stores all of the layers and is responsible for exporting them on level save.

func init_layer_manager(set_layers: Array):
	layers = set_layers
	current_layer = layers[0]
	
	

# Editor interface functions
func place(to_place):
	if to_place is GameObject:
		current_layer.place_object(to_place)
	elif to_place is Tile:
		current_layer.place_tile(to_place)
		
func remove(to_remove):
	if to_remove is GameObject:
		current_layer.remove_object(to_remove)
	elif to_remove is Vector2:
		current_layer.remove_tile(to_remove)
		
func add_layer(index: int):
	if(layers.size() >= MAX_LAYERS):
		layers.insert(index, LevelLayer.new())
	
func delete_layer(index: int):
	if(index < layers.size()):
		layers.remove(index)
	else:
		push_warning("Attempted to delete out of bounds layer.")
		
func move_layer(old_index: int, new_index: int):
	if old_index < 0 or old_index >= layers.size():
		push_warning("Tried to swap layer out of bounds")
		return
	if new_index < 0:
		new_index = 0
	elif new_index > layers.size():
		new_index = layers.size()
		
	var temp = layers.pop_at(old_index)
	if(old_index < new_index):
		new_index -= 1
	layers.insert(new_index, temp)
