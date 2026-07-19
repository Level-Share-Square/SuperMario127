extends LevelDataLoader
class_name LevelShared

const GROUND_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/ground_layer/ground_layer.tscn"
const PARALLAX_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/parallax_layer/parallax_layer.tscn"


var ground_layer_scene: PackedScene = preload(GROUND_LAYER_SCENE_PATH)
var parallax_layer_scene: PackedScene = preload(PARALLAX_LAYER_SCENE_PATH)

var layers: Array

const layer_index_offset: int = -2
const layer_spacing: int = 16


func load_in():
	load_layers(CurrentLevelData.area.layers)


func load_layers(layer_data_list: Array):
	for layer_data in layer_data_list:
		layer_data = layer_data
		add_layer(layer_data)

func get_layer_index(layer: LevelLayer):
	return layers.find(layer)

func add_layer(layer_data = null, add_to_data: bool = false):
	if not is_instance_valid(layer_data):
		var layer_metadata = LayerMetadata.new()
		layer_data = LayerData.new(layer_metadata, TileData.new(), [])
	
	var new_layer: LevelLayer
	if layer_data.layer_metadata.is_ground:
		new_layer = ground_layer_scene.instance()
	else:
		new_layer = parallax_layer_scene.instance()
	
	add_child(new_layer)
	
	new_layer.load_in(layer_data)
	layers.append(new_layer)
	
	if add_to_data:
		CurrentLevelData.area.layers.append(layer_data)


func remove_layer(index: int, remove_from_data: bool = false):
	var removed = layers[index]
	layers.remove(index)
	if remove_from_data:
		CurrentLevelData.area.layers.remove(index)
	
func set_tile(x: int, y: int, index: int, tileset_id: int, tile_id: int, palette_id : int = 0):
	layers[index].place_tile(Vector2(x, y), tileset_id, tile_id, palette_id, true, true)

func get_tile(x: int, y: int, index: int):
	return layers[index].tile_map_manager.layer_data.tile_data.get_tile_data_at(Vector2(x, y))

func is_air(tile_data: Array):
	return tile_data[0] <= 0 or tile_data[1] < 0 or tile_data[2] < 0
