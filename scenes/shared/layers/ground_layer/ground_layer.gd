class_name LevelGroundLayer
extends LevelLayer


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager: ObjectManager = $"%ObjectManager"

var autoset_tint: bool = true
var layer_tint: Color = Color.white
var order: int = 0
# Empty means always active
var activated_mission_ids: PoolIntArray = []

var last_canvas_position = Vector2.ZERO


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


