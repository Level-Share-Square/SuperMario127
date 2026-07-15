class_name LayerData
extends LevelDataResource


var layer_metadata: LayerMetadata
var tile_data: TileData
var object_data: Array


# Called when the node enters the scene tree for the first time.
func _init(set_layer_metadata: LayerMetadata, set_tile_data: TileData, set_object_data: Array = []):
	layer_metadata = set_layer_metadata
	object_data = set_object_data
	tile_data = set_tile_data


func place_tile(coords: Vector2, tileset: int, type: int, palette: int = 0) -> void:
	tile_data.set_tile(coords, tileset, type, palette)


func erase_tile(coords: Vector2) -> void:
	tile_data.erase_tile(coords)


func add_object(data) -> void:
	object_data.append(data)


func place_object(position: Vector2, data):
	data.position = position
	add_object(data)
