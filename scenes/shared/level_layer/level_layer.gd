class_name LevelLayer
extends Node2D


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager: ObjectManager = $"%ObjectManager"

var parallax_distance: int = 0
var autoset_tint: bool = true
var layer_tint: Color = Color.white

var order: int = 0
var is_ground: bool = true
# -1 means always activated
var activated_mission_id: int = -1


func load_in(layer_data: LayerData):
	tile_map_manager.load_in(layer_data)
	object_manager.load_in(layer_data)


# Tiles
func place_tile(coords, tile_set, tile, palette):
	tile_map_manager.place_tile(coords, tile_set, tile, palette)


func erase_tile(to_remove: Vector2):
	tile_map_manager.erase_tile(to_remove)


# Objects
func add_object(to_add: ObjectData):
	object_manager.create_object(to_add)


func place_object(s_position: Vector2, to_place: ObjectData):
	object_manager.place_object(s_position, to_place)


func erase_object(to_remove: GameObject):
	object_manager.erase_object(to_remove)


func set_parallax_distance(distance: int):
	parallax_distance = distance
	# set parallax layer motion scale and size scale here
	
func set_autoset_tint(to_set: bool):
	autoset_tint = to_set
	# set layer tint here

func set_order(to_set: int):
	order = to_set

func set_is_ground(to_set: bool):
	is_ground = to_set
	# set layer collision here
	
func set_layer_tint(to_set: Color):
	if(!autoset_tint):
		layer_tint = to_set
		# set layer tint here
	
func set_activated_mission_id(to_set: int):
	activated_mission_id = to_set
