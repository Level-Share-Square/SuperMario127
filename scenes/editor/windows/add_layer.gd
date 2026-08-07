extends ScrollContainer

onready var order = $"%Order"
onready var hex = $"%Hex"
onready var distance = $"%Distance"
onready var ground = $"%Ground"
onready var add_layer = $"%AddLayer"
onready var opacity = $"%Opacity"
onready var tint = $"%Tint"

var shared

func _ready():
	add_layer.connect("pressed", self, "add_layer")
	shared = get_tree().current_scene.get_shared_node()

func add_layer():
	var metadata := LayerMetadata.new(
		float(distance.text),
		Vector2.ZERO,
		tint.pressed,
		Color(hex.text),
		int(order.text),
		ground.pressed,
		"New Layer",
		false,
		PoolIntArray(),
		false,
		float(opacity.text)
	)
	
	var data := LayerData.new(metadata, TileData.new(), [])
		
	shared.add_layer(data, true)
