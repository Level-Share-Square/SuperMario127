extends Action
class_name MergeLayerAction

var layer_id
var other_layer_id
var shared: LevelShared

var old_data: Array
var old_orders: Array
var new_data

func _do():
	var layer = shared.get_layer(layer_id)
	var other_layer = shared.get_layer(other_layer_id)
	
	var base_td: TileData = layer.layer_data.tile_data
	var other_td: TileData = other_layer.layer_data.tile_data
	var new_tile_data := TileData.new()
	
	for pos in base_td.used_tiles:
		var tile_data = base_td.get_tile_data_at(pos)
		new_tile_data.set_tile(pos, tile_data[0], tile_data[1], tile_data[2])
	
	for pos in other_td.used_tiles:
		var tile_data = other_td.get_tile_data_at(pos)
		new_tile_data.set_tile(pos, tile_data[0], tile_data[1], tile_data[2])

	var new_object_data: Array = layer.layer_data.object_data + other_layer.layer_data.object_data
	
	var new_layer_data := LayerData.new(
		LayerData.duplicate_metadata(other_layer.layer_data.layer_metadata), 
		new_tile_data,
		new_object_data
	)
	
	if layer.layer_data.layer_metadata.is_origin or other_layer.layer_data.layer_metadata.is_origin:
		new_layer_data.layer_metadata.is_origin = true
		new_layer_data.layer_metadata.is_ground = true
		
	old_data = [layer.layer_data, other_layer.layer_data]
	old_orders = [layer.layer_data.layer_metadata.order, other_layer.layer_data.layer_metadata.order]
	new_layer_data.layer_metadata.order -= 1
	
	var editor = shared.get_parent()
		
	shared.remove_layer(layer_id, true)
	shared.remove_layer(other_layer_id, true)
	yield(shared, "child_order_changed")
	var new_layer = shared.add_layer(new_layer_data, true, new_layer_data.layer_metadata.order)
	
	
	if new_layer_data.layer_metadata.is_origin:
		shared.origin = new_layer
	
	new_data = new_layer.layer_data
	
	if (editor.layer == layer_id or editor.layer == other_layer_id):
		editor.get_node("%LayerDropdown").select_layer(new_layer_data.layer_metadata.order, false)
	
	editor.get_node("%LayerDropdown").update_layers()
	

func _undo():

	shared.remove_layer(new_data.layer_metadata.layer_uuid, true)
	yield(shared, "child_order_changed")
	var layer_one = shared.add_layer(old_data[0], true, old_orders[0])
	var layer_two = shared.add_layer(old_data[1], true, old_orders[1])

	if layer_one.layer_data.layer_metadata.is_origin: shared.origin = layer_one
	if layer_two.layer_data.layer_metadata.is_origin: shared.origin = layer_two
	
	var editor = shared.get_parent()
	if editor.layer == new_data.layer_metadata.layer_uuid:
		editor.get_node("%LayerDropdown").select_layer(old_data[1].layer_metadata.order, false)

	editor.get_node("%LayerDropdown").update_layers()
