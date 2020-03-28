extends Node2D

class_name GameObject

var mode := 0
var level_object = null

var enabled = true

var base_savable_properties : PoolStringArray = ["position", "scale", "rotation", "enabled", "visible"]
var savable_properties : PoolStringArray = []

var base_editable_properties : PoolStringArray = ["enabled", "visible", "rotation", "scale", "position"]
var editable_properties : PoolStringArray = []

func is_savable_property(key) -> bool:
	for savable_property in (base_savable_properties + savable_properties):
		if key == savable_property:
			return true
	
	return false

func set_property(key, value, change_level_object):
	self[key] = value
	if change_level_object and is_savable_property(key):
		level_object.properties[key] = value

func set_property_by_index(index, value, change_level_object):
	print(value)
	var key = (base_savable_properties + savable_properties)[index]
#	set_property(key, value, change_level_object)
