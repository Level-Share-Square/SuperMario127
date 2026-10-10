extends GameObject
class_name EventObject

var events: Array = []

func _ready():
	var wait_event := WaitEvent.new()
	wait_event.properties["time"] = 2
	var camera_event := CameraCutsceneEvent.new()
	camera_event.properties["do_reverse"] = true
	camera_event.properties["to"] = Vector2(0, 0)
	camera_event.properties["time"] = 2
	var zoom_event := CameraZoomEvent.new()
	zoom_event.properties["zoom_time"] = 2
	zoom_event.properties["target_zoom"] = 2
	
	events = [wait_event, zoom_event, camera_event]
	OS.set_clipboard(LevelCodeSerializer.serialize_data_array(events))
	if get_tree().current_scene.name == "Player": run_event()

func _register_properties():
	register_property(4, "events", events, true)

func run_event():
	if events.size() == 0:
		print("Event queue finished!")
		return
	
	var event: Event = events.pop_front()
	event.connect("event_finished", self, "run_event")
	event.do_event(self)
