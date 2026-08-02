class_name EditLayerAction
extends Action

var shared: LevelShared
var layer_index: int
var property: String

var new_value
var old_value

func change_property(value) -> void:
	var metadata: LayerMetadata = shared.get_layer_at(layer_index).layer_data.layer_metadata
	old_value = metadata[property]
	shared.edit_layer(metadata.layer_uuid, property, value)
	

func _do():
	change_property(new_value)
	
func _undo():
	change_property(old_value)
