class_name LevelLayer
extends ParallaxBackground


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager = $"%ObjectManager"

var level_layer_data: LevelLayerData


func load_in(level_data: LevelData, level_area: LevelArea):
	tile_map_manager.load_in(level_data, level_area)
	object_manager.load_in(level_data, level_area)
	
	
# Interface functions
func place(to_place):
	if to_place is GameObject:
		place_object(to_place)
	elif to_place is Tile:
		place_tile(to_place)
		
func remove(to_remove):
	if to_remove is GameObject:
		remove_object(to_remove)
	elif to_remove is Vector2:
		remove_tile(to_remove)
	

# Logic functions

func place_tile(to_place: Tile):
	tile_map_manager.place_tile(to_place)

func place_object(to_place: GameObject):
	object_manager.place_object(to_place)
	
func remove_object(to_remove: GameObject):
	object_manager.remove_object(to_remove)
	
func remove_tile(to_remove: Vector2):
	tile_map_manager.remove_tile(to_remove)
	

