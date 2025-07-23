class_name PropertyEditor
extends HBoxContainer


enum Subgroups {Bool, Misc, Dialogue, Warps}

export(Subgroups) var subgroup: int = 1

var object: GameObject
var object_data: ObjectData
var index: int
var alias: String


func setup(value, hints: PropertyHints) -> void:
	alias = hints.alias
	
	load_object_value()


func load_object_value():
	pass


func set_property_in_object(value) -> void:
	object.set_property_by_index(index, value, true)


func get_property_in_object():
	return object_data.properties[index]
