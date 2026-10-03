extends Event
class_name CameraShakeEvent

var shake_strength: float = 4.0

func do_event(handler: Node) -> void:
	var camera: Camera2D = handler.get_tree().current_scene.get_node(handler.get_tree().current_scene.camera)
	
	camera.shake_strength = shake_strength
	camera.shake = true
	
	.do_event(handler)
