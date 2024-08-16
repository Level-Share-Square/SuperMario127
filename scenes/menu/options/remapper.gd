extends CenterContainer

const INPUT_WAIT_TEXT: String = "Waiting..."

func start_listening(keybind: VBoxContainer):
	keybind.change_button_text(INPUT_WAIT_TEXT)

func _input(event: InputEvent):
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return
	
	#var action: Dictionary = bindings_util.decode_event(event)
