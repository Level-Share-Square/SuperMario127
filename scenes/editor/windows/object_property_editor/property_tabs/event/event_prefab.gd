extends VBoxContainer

onready var event_container = $"%EventContainer"

func add_event(event_panel: EventPanel):
	event_container.add_child(event_panel)
	event_panel.populate_name()
