class_name ChangePropertyAction
extends Action

var object: GameObject
var original_properties: Dictionary
var changed_properties: Dictionary


func set_properties():
	for property_name in changed_properties.keys():
		var new_value = changed_properties[property_name]
		original_properties[property_name] = object.level_object.get(property_name)
		object.set_property(property_name, new_value)

func restore_properties():
	for property_name in original_properties.keys():
		var original_value = original_properties[property_name]
		object.set_property(property_name, original_value)
		
func _do():
	set_properties()
	
func _undo():
	restore_properties()
