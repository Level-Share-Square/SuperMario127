class_name LevelLayer
extends ParallaxBackground


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager = $"%ObjectManager"

var parallax_distance: int = 0
var autoset_tint: bool = true
var layer_tint: Color = Color(1, 1, 1, 1)

var order: int = 0
var is_ground: bool = true
# -1 means always activated
var activated_mission_id: int = -1


func load_in(level_data: LevelDataOld, level_area: LevelAreaOld):
	tile_map_manager.load_in(level_data, level_area)
	object_manager.load_in(level_data, level_area)

# Interface functions

func place_tile(to_place: TileData):
	tile_map_manager.place_tile(to_place)


func place_object(to_place: GameObject):
	object_manager.place_object(to_place)


func remove_object(to_remove: GameObject):
	object_manager.remove_object(to_remove)


func remove_tile(to_remove: Vector2):
	tile_map_manager.remove_tile(to_remove)


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
