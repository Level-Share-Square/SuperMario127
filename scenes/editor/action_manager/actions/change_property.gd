class_name ChangePropertyAction
extends Action

var object: GameObject
var original_properties: Dictionary
var changed_properties: Dictionary

func set_properties(_object: GameObject, _original_properties: Dictionary, _changed_properties: Dictionary):
	for property_name in _changed_properties.keys():
		if _original_properties.empty():
			_original_properties[property_name] = _object[property_name]
		var new_value = _changed_properties[property_name]
		_object.register_property(property_name, new_value, true)

func restore_properties(_object: GameObject, _original_properties: Dictionary, _changed_properties: Dictionary):
	for property_name in _original_properties.keys():
		var original_value = _original_properties[property_name]
		_object.register_property(property_name, original_value, true)

## note that this function is only needed for tools like move and rotate, which change
## object properties prior to setting them. if you're setting properties from say, the property
## menu, then you can just call set_properties directly and itll handle this for you
func store_original_properties(_object: GameObject, _original_properties: Dictionary, _changed_properties: Dictionary):
	for property_name in _changed_properties.keys():
		_original_properties[property_name] = _object[property_name]

func _do():
	set_properties(object, original_properties, changed_properties)
	
func _undo():
	restore_properties(object, original_properties, changed_properties)
