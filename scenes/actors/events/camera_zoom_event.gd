extends Event
class_name CameraZoomEvent

var properties: Dictionary = {
	"zoom_time": 4,
	"target_zoom": 2,
}

func do_event(handler: Node) -> void:
	yield(handler.get_tree(), "idle_frame")
	var camera: Camera2D = handler.get_tree().current_scene.get_node(handler.get_tree().current_scene.camera)
	
	if !is_equal_approx(camera.zoom.x, properties["target_zoom"]):
		camera.set_zoom_tween(Vector2(properties["target_zoom"], properties["target_zoom"]), properties["zoom_time"])
		yield(camera.zoom_tween, "tween_all_completed")

	.do_event(handler)
