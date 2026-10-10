extends Event
class_name CameraShakeEvent

var properties: Dictionary = {
	"shake_strength": 4
}

func do_event(handler: Node) -> void:
	var camera: Camera2D = handler.get_tree().current_scene.get_node(handler.get_tree().current_scene.camera)
	
	camera.shake_strength = properties["shake_strength"]
	camera.shake = true
	
	.do_event(handler)
