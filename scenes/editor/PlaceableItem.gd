extends Node

class_name PlaceableItem

export var tileset_id := 0
export var tile_id := 0
export var object_id := 0
export var is_object := false
export var object_center := Vector2(0, 0)
export var tile_mode_offset := Vector2(0, 0)
export var object_size := Vector2(0, 0)
export var z_index := 0
export var change_to : String = self.name

export var icon : Texture = null
export var preview : Texture = null
