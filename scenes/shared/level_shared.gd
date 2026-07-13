extends LevelDataLoader


const LAYER_SCENE_PATH: String = "res://scenes/shared/level_layer/level_layer.tscn"


var layer_scene: PackedScene = preload(LAYER_SCENE_PATH)

var layers: Array


func load_in():
	load_layers(CurrentLevelData.area.layers)


func load_layers(layer_data_list: Array):
	for layer_data in layer_data_list:
		layer_data = layer_data
		add_layer(layer_data)


func add_layer(layer_data = null, add_to_data: bool = false):
	var new_layer: LevelLayer = layer_scene.instance()
	add_child(new_layer)
	
	if not is_instance_valid(layer_data):
		var layer_metadata = LayerMetadata.new()
		layer_data = LayerData.new(layer_metadata, TileData.new(), [])
	
	new_layer.load_in(layer_data)
	
	
	if add_to_data:
		CurrentLevelData.area.layers.append(layer_data)


func remove_layer(index: int):
	var removed: LevelLayer = layers[index]
	layers.remove(index)
