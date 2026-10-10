extends PropertyTab

const EVENT_PANEL = preload("res://scenes/editor/windows/object_property_editor/property_tabs/event/event_panel.tscn")

onready var event_prefab = $"%EventPrefab"

func _ready():
	var object: EventTrigger = objects.keys()[0]
	for event in object.events:
		var event_panel = EVENT_PANEL.instance()
		event_panel.held_event = event
		event_prefab.add_event(event_panel)

func load_properties(_editor, _objects):
	editor = _editor
	objects = _objects
