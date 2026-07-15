class_name AreaData
extends LevelDataResource


var header: AreaHeader
# Array of LayerData
var layers: Array


func _init(set_header: AreaHeader, set_layers: Array):
	header = set_header
	layers = set_layers


func get_objects_on_ground() -> Array:
	var objects: Array = []
	
	for layer in layers:
		if layer.layer_metadata.is_ground:
			objects.append_array(layer.object_data)
	
	return objects
