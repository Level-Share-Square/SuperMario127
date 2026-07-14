class_name ObjectData
extends Resource


const PALETTE_PROP_NAME: String = "palette"
const POSITION_PROP_NAME: String = "position"
const ENABLED_PROP_NAME: String = "enabled"


var metadata: ObjectMetadata

# Dictionary of String and int
export var property_ids: Dictionary
# Dictionaries of int and Variant
var default_values: Dictionary = {}
var properties: Dictionary = {}


func _init(s_metadata: ObjectMetadata, s_properties: Dictionary = {}):
	metadata = s_metadata
	properties = s_properties


func set_property(property_name: String, value) -> void:
	if property_name == PALETTE_PROP_NAME:
		if value is int:
			metadata[PALETTE_PROP_NAME] = value
		else:
			return
	elif property_name == POSITION_PROP_NAME:
		if value is Vector2:
			metadata[POSITION_PROP_NAME] = value
		else:
			return
	elif property_name == ENABLED_PROP_NAME:
		if value is bool:
			metadata[ENABLED_PROP_NAME] = value
		else:
			return
	
	var property_id: int = property_ids.get(property_name, -1)
	if property_id < 0:
		return
	
	set_property_by_id(property_id, value)


func set_property_by_id(property_id: int, value) -> void:
	if properties.has(property_id):
		if is_default_value(property_id, value):
			properties.erase(property_id)
		else:
			properties[property_id] = value
	else:
		properties.get_or_add(property_id, value)


func is_default_value(property_id: int, value) -> bool:
	return default_values.has(property_id) and default_values.get(property_id) == value
