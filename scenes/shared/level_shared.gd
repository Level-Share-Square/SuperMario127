extends LevelDataLoader


const GROUND_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/ground_layer/ground_layer.tscn"
const PARALLAX_LAYER_SCENE_PATH: String = "res://scenes/shared/layers/parallax_layer/parallax_layer.tscn"


var ground_layer_scene: PackedScene = preload(GROUND_LAYER_SCENE_PATH)
var parallax_layer_scene: PackedScene = preload(PARALLAX_LAYER_SCENE_PATH)

var layers: Array


func load_in():
	load_layers(CurrentLevelData.area.layers)


func load_layers(layer_data_list: Array):
	for layer_data in layer_data_list:
		layer_data = layer_data
		add_layer(layer_data)


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
	
	if add_to_data:
		CurrentLevelData.area.layers.append(layer_data)


func remove_layer(index: int):
	var removed = layers[index]
	layers.remove(index)
