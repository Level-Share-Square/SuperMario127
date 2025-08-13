class_name LevelLayer
extends ParallaxBackground


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager = $"%ObjectManager"


func load_in(level_data: LevelData, level_area: LevelArea):
	tile_map_manager.load_in(level_data, level_area)
	object_manager.load_in(level_data, level_area)
