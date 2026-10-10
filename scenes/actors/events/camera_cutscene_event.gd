extends Event
class_name CameraCutsceneEvent

var properties: Dictionary = {
	"time": 4,
	"max_pan_distance": 800,
	"to": Vector2(1, 1),
	"do_reverse": true,
}

func do_event(handler: Node) -> void:
	var cutscene := CameraCutscene.new()
	
	cutscene.time = properties["time"]
	cutscene.max_pan_distance = properties["max_pan_distance"]
	cutscene.to = properties["to"]
	cutscene.do_reverse = properties["do_reverse"]
	cutscene.owner = handler
	
	var camera: Camera2D = handler.get_tree().current_scene.get_node(handler.get_tree().current_scene.camera)
	
	camera.queue_cutscene(cutscene)
	if not camera.in_cutscene: camera.start_queue()
	
	yield(camera, "finished_cutscene")
	.do_event(handler)
