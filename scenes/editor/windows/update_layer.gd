extends ScrollContainer

onready var index = $"%Index"
onready var order = $"%UpOrder"
onready var hex = $"%UpHex"
onready var distance = $"%UpDistance"
onready var opacity = $"%UpOpacity"
onready var ground = $"%UpGround"
onready var tint = $"%UpTint"
onready var update_layer = $"%UpdateLayer"


var shared

func _ready():
	update_layer.connect("button_down", self, "update_layer")
	index.connect("text_changed", self, "on_new_index")
	shared = get_tree().current_scene.get_shared_node()

func update_layer():
	var layer: LevelLayer = shared.get_layer_at(int(index.text))
	var layer_index = shared.get_layer_index(layer)
	
	var metadata := LayerMetadata.new(
		float(distance.text),
		Vector2.ZERO,
		tint.pressed,
		Color(hex.text),
		int(order.text),
		ground.pressed,
		"New Layer",
		PoolIntArray(),
		false,
		float(opacity.text)
	)
	
	var data := LayerData.new(metadata, layer.layer_data.tile_data, layer.layer_data.object_data)
	
	shared.edit_layer(layer_index, data)

func on_new_index(text):
	if int(text) >= shared.layers.size():
		return
	if shared.layers[int(text)]:
		var layer: LevelLayer = shared.get_layer_at(int(text))
		var metadata: LayerMetadata = layer.layer_data.layer_metadata
		distance.text = str(metadata.parallax_distance)
		order.text = str(metadata.order)
		hex.text = str(metadata.layer_tint.to_html(true))
		opacity.text = str(metadata.layer_opacity)
		ground.pressed = metadata.is_ground
		tint.pressed = metadata.autoset_tint
