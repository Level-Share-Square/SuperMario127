extends PanelContainer

onready var paste_action = $"%PasteAction"
onready var selection_actions = $"%SelectionActions"

func _ready():
	verify_clipboard()

func verify_clipboard():
	var clipboard = JSON.parse(OS.get_clipboard()).result
	if clipboard is Array:
		paste_action.show()
	else:
		paste_action.hide()

func show_selection_actions():
	verify_clipboard()
	selection_actions.show()

func hide_selection_actions():
	selection_actions.hide()
	verify_clipboard()
