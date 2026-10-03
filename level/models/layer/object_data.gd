class_name ObjectData
extends LevelDataResource


const PALETTE_PROP_ID: int = -2
const POSITION_PROP_ID: int = -1


var metadata: ObjectMetadata

## dictionary of int and Variant
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
		_:
			if properties.has(property_id):
				properties[property_id] = value
			else:
				properties.get_or_add(property_id, value)


func get_property(property_id: int):
	match property_id:
		PALETTE_PROP_ID:
			return metadata.palette
		POSITION_PROP_ID:
			return metadata.position
		_:
			return properties.get(property_id)
