extends ParallaxScroll

onready var editor = owner
onready var shared = editor.get_shared_node()

func _ready():
	yield(editor, "ready")
	editor.action_manager.connect("action", self, "_update_parallax", [editor.layer])
	editor.action_manager.connect("do", self, "_update_parallax", [editor.layer])
	editor.action_manager.connect("undo", self, "_update_parallax", [editor.layer])

func _update_parallax(layer: int):
	var cur_layer = shared.layers[editor.layer]
	if cur_layer is LevelParallaxLayer:
		set_parallax_distance(shared.layers[editor.layer].parallax_scroll.parallax_distance)
	else:
		set_parallax_distance(0)
	_update_scroll()
