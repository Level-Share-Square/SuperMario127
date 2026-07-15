class_name ObjectData
extends LevelDataResource


const PALETTE_PROP_ID: int = -3
const POSITION_PROP_ID: int = -2
const ENABLED_PROP_ID: int = -1


var metadata: ObjectMetadata

# Dictionary of String and int
export var property_ids: Dictionary
# Dictionaries of int and Variant
var default_values: Dictionary = {}
var properties: Dictionary = {}


func _init(s_metadata: ObjectMetadata, s_properties: Dictionary = {}):
	metadata = s_metadata
	properties = s_properties


func set_property(property_id: int, value) -> void:
	match property_id:
		PALETTE_PROP_ID:
			if value is int:
				metadata.palette = value
		POSITION_PROP_ID:
			if value is Vector2:
				metadata.position = value
		ENABLED_PROP_ID:
			if value is bool:
				metadata.enabled = value
		_:
			if is_default_value(property_id, value):
				if properties.has(property_id):
					properties.erase(property_id)
				return
			
			if properties.has(property_id):
				properties[property_id] = value
			else:
				properties.get_or_add(property_id, value)


func is_default_value(property_id: int, value) -> bool:
	return default_values.has(property_id) and default_values.get(property_id) == value
