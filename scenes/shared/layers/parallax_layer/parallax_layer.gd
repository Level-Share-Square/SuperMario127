class_name LevelParallaxLayer
extends LevelLayer


onready var tile_map_manager: TileMapManager = $"%TileMapManager"
onready var object_manager: ObjectManager = $"%ObjectManager"


var parallax_distance: float = 0


func _process(delta: float) -> void:
#	var canvas_position: Vector2 = get_canvas_transform().origin
	var parallax_factor: float = parallax_distance
	position = -get_canvas_transform().origin * parallax_factor


func load_in(layer_data: LayerData):
	.load_in(layer_data)
	
	modulate = layer_tint
	z_index = order
	
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


func erase_object(to_remove):
	object_manager.erase_object(to_remove)
	
