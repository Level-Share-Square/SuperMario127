class_name LevelLayer
extends Node2D


const LAYER_Z_SPACING: int = 8 # amount of z indices the layer has on either side of it
const DEFAULT_BACKGROUND_COLOR: Color = Color(0.545098, 0.545098, 0.545098)


var layer_tint: Color = Color.white
var autoset_tint: bool = true
var order: int = 0 setget set_order
# Empty means always active
var activated_mission_ids: PoolIntArray = []


func load_in(layer_data: LayerData):
	layer_tint = layer_data.layer_metadata.layer_tint
	autoset_tint = layer_data.layer_metadata.autoset_tint
	set_order(layer_data.layer_metadata.order)
	activated_mission_ids = layer_data.layer_metadata.activated_mission_ids


func set_order(s_order: int) -> void:
	order = s_order
	_update_z_index()


func set_layer_modulate(color: Color) -> void:
	layer_tint = color
	_update_modulate()


func _update_z_index() -> void:
	z_index = order * LAYER_Z_SPACING * 2


func _update_modulate() -> void:
	if autoset_tint:
		modulate = _modulate_autoset()
	else:
		modulate = layer_tint


func _modulate_autoset() -> Color:
	return Color.white


# Tiles
func place_tile(coords, tile_set, tile, palette):
	pass


func erase_tile(to_remove: Vector2):
	pass


# Objects
func add_object(to_add: ObjectData):
	pass


func place_object(s_position: Vector2, to_place: ObjectData):
	pass


func erase_object(to_remove: GameObject):
	pass


