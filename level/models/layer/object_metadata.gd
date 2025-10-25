class_name ObjectMetadata
extends Resource

var type_id: int = 0
var palette: int = 0
var enabled: bool = true
var rotation: int = 0


func _init(set_type_id, set_palette, set_enabled, set_rotation):
	type_id = set_type_id
	palette = set_palette
	enabled = set_enabled
	rotation = set_rotation
