extends Event
class_name CameraShakeEvent

var properties: Dictionary = {
	"shake_strength": 4
}

func get_internal_name() -> String:
	return "camera_shake_event"

func get_display_name() -> String:
	return "Shake the camera"

func get_display_suffix() -> String:
	var suffix: String = " (Strength: col_open%scol_close)"
	suffix = suffix.replace("col_open", COLOR_OPENING)
	suffix = suffix.replace("col_close", COLOR_CLOSING)
	suffix = suffix % properties["shake_strength"]
	return suffix

func do_event(handler: Node) -> void:
	var camera: Camera2D = handler.get_tree().current_scene.get_node(handler.get_tree().current_scene.camera)
	
	camera.shake_strength = properties["shake_strength"]
	camera.shake = true
	
	.do_event(handler)
