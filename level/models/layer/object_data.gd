class_name ObjectData
extends Resource

var metadata: ObjectMetadata
var properties: Array = []


func _init(s_metadata: ObjectMetadata, s_properties: Array):
	metadata = s_metadata
	properties = s_properties
