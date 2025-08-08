extends Node2D


const LAYER_SCENE_PATH: String = "res://scenes/shared/level_layer/level_layer.tscn"


var layer_scene: PackedScene = preload(LAYER_SCENE_PATH)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func load_layers(layer_data: Array):
	for layer in layer_data:
		layer = layer as LevelLayerData
		add_layer()


func add_layer(index: int):
	var new_layer = layer_scene.instance()
	new_layer.connect("ready", new_layer, "setup", [layer_data])
	
	add_child(new_layer)


func remove_layer(index: int):
	
