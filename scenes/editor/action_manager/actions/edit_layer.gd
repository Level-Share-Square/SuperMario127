class_name EditLayerAction
extends Action

var shared: LevelShared
var layer_index: int
var property: String

var new_value
var old_value

func change_property(value) -> void:
	old_value = shared.get_layer_at(layer_index).layer_data.layer_metadata[property]
	shared.edit_layer(layer_index, property, value)
	

func _do():
	change_property(new_value)
	
func _undo():
	change_property(old_value)
