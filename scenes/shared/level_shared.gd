extends LevelDataLoader


const LAYER_SCENE_PATH: String = "res://scenes/shared/level_layer/level_layer.tscn"


var layer_scene: PackedScene = preload(LAYER_SCENE_PATH)

var current_area_id: int = 0
var current_area: LevelArea 

var layers: Array = []


func load_in(level_data: LevelData, level_area: LevelArea):
	load_layers(level_area.layers)


func load_layers(layer_data: Array):
	for layer in layer_data:
		layer = layer as LevelLayerData
		add_layer()


func add_layer(id: int):
	var new_layer = layer_scene.instance()
	new_layer.connect("ready", new_layer, "setup", [layer_data])
	
	add_child(new_layer)


func remove_layer(id: int):
	
