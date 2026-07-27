class_name LevelLayer
extends Node2D

var layer_data: LayerData

const LAYER_Z_SPACING: int = 8 # amount of z indices the layer has on either side of it
const DEFAULT_BACKGROUND_COLOR: Color = Color(0.545098, 0.545098, 0.545098)


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager: ObjectManager = $"%ObjectManager"

var layer_tint: Color = Color.white
var autoset_tint: bool = true
var order: int = 0 setget set_order
# Empty means always active
var activated_mission_ids: PoolIntArray = []

func load_in(layer_data: LayerData):
	autoset_tint = layer_data.layer_metadata.autoset_tint
	activated_mission_ids = layer_data.layer_metadata.activated_mission_ids
	var tint = layer_data.layer_metadata.layer_tint
	# A value of layer tint should be 1-100
	set_layer_modulate(Color(tint.r * tint.a, tint.g * tint.a, tint.b * tint.a, layer_data.layer_metadata.layer_opacity))
	set_order(layer_data.layer_metadata.order)
	self.layer_data = layer_data


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
func place_tile(coords, tile_set, tile, palette, update_autotile, modify_data):
	pass


func erase_tile(to_remove: Vector2):
	pass


# Objects
func add_object(to_add: ObjectData, modify_data: bool = false):
	pass


func place_object(to_place: ObjectData, modify_data: bool = false):
	pass


func erase_object(to_remove):
	pass


func get_object_at_position(position: Vector2):
	for object in object_manager.get_children():
		if object.position.is_equal_approx(position):
			return object
	return null
