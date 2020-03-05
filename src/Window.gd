extends WindowDialog

onready var close = get_node("Close")

func _ready():
	popup_centered()
	pass

func _process(delta):
	if close.pressed:
		hide()

