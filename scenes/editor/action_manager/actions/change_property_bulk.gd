class_name ChangePropertyBulkAction
extends ChangePropertyAction

var affected_objects: Dictionary

func _do():
	for object in affected_objects.keys():
		var properties_dict: Dictionary = affected_objects[object]
		var original_properties: Dictionary = properties_dict.original_properties
		var changed_properties: Dictionary = properties_dict.changed_properties
		print("do: ", original_properties)
		set_properties(object, original_properties, changed_properties)
		print("do: ", original_properties)

func _undo():
	for object in affected_objects.keys():
		var properties_dict: Dictionary = affected_objects[object]
		var original_properties: Dictionary = properties_dict.original_properties
		var changed_properties: Dictionary = properties_dict.changed_properties
		restore_properties(object, original_properties, changed_properties)

## note that this function is only needed for tools like move and rotate, which change
## object properties prior to setting them. if you're setting properties from say, the property
## menu, then you can just call set_properties directly and itll handle this for you
func bulk_store_original_properties():
	for object in affected_objects.keys():
		var properties_dict: Dictionary = affected_objects[object]
		var original_properties: Dictionary = properties_dict.original_properties
		var changed_properties: Dictionary = properties_dict.changed_properties
		print("store: ", original_properties)
		store_original_properties(object, original_properties, changed_properties)
		print("store: ", original_properties)
