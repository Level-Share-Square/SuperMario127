extends TabContainer

var start_info: Label
var event_container: Control
var event_list: EventList

func _enter_tree():
	event_container = $"%EventContainer"
	start_info = $"%StartInfo"
	event_list = $"%EventList"

func add_event(event_panel: EventPanel):
	event_container.add_child(event_panel)
	event_panel.populate_name()
	event_panel.connect("open_properties", self, "set_current_tab", [2])
	current_tab = 0

func load_info(start_text: String):
	start_info.text = start_text
	event_list.populate_list()
