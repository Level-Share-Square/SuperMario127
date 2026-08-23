class_name LevelLayer
extends Node2D

var layer_data: LayerData

const LAYER_Z_SPACING: int = 8 # amount of z indices the layer has on either side of it
const DEFAULT_BACKGROUND_COLOR: Color = Color(0.545098, 0.545098, 0.545098)


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager: ObjectManager = $"%ObjectManager"

var layer_tint: Color = Color.white
var autoset_tint: bool = false
var order: int = 0 setget set_order
# Empty means always active
var activated_mission_ids: PoolStringArray = []
# if set to -1, there is no minimum/maximum amount
var min_shines: int = -1
var max_shines: int = -1

func load_in(layer_data: LayerData):
	autoset_tint = layer_data.layer_metadata.autoset_tint
	activated_mission_ids = layer_data.layer_metadata.activated_mission_ids
	min_shines = layer_data.layer_metadata.min_shines
	max_shines = layer_data.layer_metadata.max_shines
	var tint = layer_data.layer_metadata.layer_tint
	# A value of layer tint should be 1-100
	set_layer_modulate(tint, layer_data.layer_metadata.layer_opacity)
	set_order(layer_data.layer_metadata.order)
	visible = layer_data.layer_metadata.layer_visible
	self.layer_data = layer_data
	
	tile_map_manager.load_in(layer_data)
	object_manager.load_in(layer_data)


func set_order(s_order: int) -> void:
	order = s_order
	_update_z_index()


func set_layer_modulate(tint: Color, opacity: float) -> void:
	layer_tint = Color(tint.r * tint.a, tint.g * tint.a, tint.b * tint.a, opacity)
	_update_modulate()


func _update_z_index() -> void:
	z_index = order * LAYER_Z_SPACING * 2

func _update_modulate() -> void:
	if autoset_tint:
		modulate = _modulate_autoset()
	else:
		modulate = layer_tint


func _modulate_autoset() -> Color:
	return layer_tint

func find_objects_in_rect(rect: Rect2) -> Array:
	var found_objects: Array = []
	get_global_transform()
	for object in object_manager.get_children():
		if rect.intersects(object.get_global_editor_rect()):
			found_objects.append(object)
			
	return found_objects

# Tiles
func place_tile(coords, tile_set, tile, palette, update_autotile, modify_data):
	tile_map_manager.place_tile(coords, tile_set, tile, palette, update_autotile, modify_data)


func erase_tile(to_remove: Vector2):
	tile_map_manager.erase_tile(to_remove)


# Objects
func add_object(to_add: ObjectData, modify_data: bool = false):
	return object_manager.place_object(to_add, modify_data)


func place_object(to_place: ObjectData, modify_data: bool = false):
	return object_manager.place_object(to_place, modify_data)

func setup_object(to_place: ObjectData):
	return [object_manager.create_object(to_place), funcref(object_manager, "add_child")]

func erase_object(to_remove):
	object_manager.erase_object(to_remove)


func get_object_at_position(pos: Vector2):
	for object in object_manager.get_children():
		if object.position.is_equal_approx(pos):
			return object
	return null
