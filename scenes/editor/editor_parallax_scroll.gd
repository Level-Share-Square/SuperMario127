extends ParallaxScroll

signal update_parallax

onready var editor = owner
onready var shared = editor.get_shared_node()

func _ready():
	yield(editor, "ready")
	editor.action_manager.connect("action", self, "_update_parallax")
	editor.action_manager.connect("undo", self, "_update_parallax")
	editor.action_manager.connect("redo", self, "_update_parallax")

func _update_parallax():
	var cur_layer = shared.layer_dictionary.get(editor.layer)
	if cur_layer is LevelParallaxLayer:
		set_parallax_distance(shared.layer_dictionary[editor.layer].parallax_scroll.parallax_distance)
		set_lock_axis(shared.layer_dictionary[editor.layer].parallax_scroll.lock_axis)
	else:
		set_parallax_distance(0)
		set_lock_axis(LayerMetadata.LockAxis.None)
	_update_scroll()
	emit_signal("update_parallax")

func layer_picked():
	_update_parallax()

func corrected_mouse_position() -> Vector2:
	return get_local_mouse_position()
