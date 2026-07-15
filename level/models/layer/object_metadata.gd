class_name ObjectMetadata
extends LevelDataResource


var type_id: int = 0
var palette: int = 0
var position: Vector2 = Vector2.ZERO
var enabled: bool = true


func _init(s_position: Vector2, s_type_id: int, s_enabled: bool = true, s_palette: int = 0):
	type_id = s_type_id
	palette = s_palette
	position = s_position
	enabled = s_enabled
