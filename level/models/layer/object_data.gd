class_name ObjectData
extends Resource

var metadata: ObjectMetadata
var properties: Array = []


func _init(set_metadata, set_properties):
	metadata = set_metadata
	properties = set_properties
