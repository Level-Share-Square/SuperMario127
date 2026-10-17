extends Event
class_name CameraZoomEvent

var properties: Dictionary = {
	"zoom_time": 4,
	"target_zoom": 2,
}

var property_overrides: Dictionary = {}

var property_info: Dictionary = {}

func get_internal_name() -> String:
	return "camera_zoom_event"

func get_display_name() -> String:
	return "Zoom the camera"

func get_display_suffix() -> String:
	var suffix: String = " to col_openx%scol_close for col_open%scol_close seconds"
	suffix = suffix.replace("col_open", COLOR_OPENING)
	suffix = suffix.replace("col_close", COLOR_CLOSING)
	suffix = suffix % [properties["target_zoom"], properties["zoom_time"]]
	return suffix

func do_event(handler: Node) -> void:
	yield(handler.get_tree(), "idle_frame")
	var camera: Camera2D = handler.get_tree().current_scene.get_node(handler.get_tree().current_scene.camera)
	
	if !is_equal_approx(camera.zoom.x, properties["target_zoom"]):
		camera.set_zoom_tween(Vector2(properties["target_zoom"], properties["target_zoom"]), properties["zoom_time"])
		yield(camera.zoom_tween, "tween_all_completed")

	.do_event(handler)
