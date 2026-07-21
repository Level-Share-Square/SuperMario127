class_name ObjectMetadata
extends LevelDataResource


var type_id: int = 0
var palette: int = 0
var position: Vector2 = Vector2.ZERO


func _init(s_position: Vector2 = Vector2(0, 0), s_type_id: int = 1, s_palette: int = 0):
	type_id = s_type_id
	palette = s_palette
	position = s_position
