extends ParallaxScroll

onready var layer_switcher = $"%Layers"
onready var editor = owner
onready var shared = editor.get_shared_node()

func _ready() -> void:
	layer_switcher.connect("layer_changed", self, "_update_parallax")
	
func _update_parallax(layer: int):
	var cur_layer = shared.layers[editor.layer]
	if(cur_layer is LevelParallaxLayer):
		set_parallax_distance(shared.layers[editor.layer].parallax_scroll.parallax_distance)
	else:
		set_parallax_distance(0)
	_update_scroll()
