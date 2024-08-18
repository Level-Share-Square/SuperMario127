extends CenterContainer

const INPUT_WAIT_TEXT: String = "Waiting..."
var is_listening: bool

func start_listening(keybind: VBoxContainer, parent: GridContainer):
	for child in parent.get_children():
		if child is KeybindButton:
			child.change_button_text("")
	keybind.change_button_text(INPUT_WAIT_TEXT)
	
	# let's not pick up the key that pressed the button
	yield(get_tree(), "idle_frame")
	is_listening = true

func _unhandled_input(event: InputEvent):
	if not is_listening: return
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return
	
	var action: Dictionary = bindings_util.decode_event(event)
	
	
	is_listening = false
