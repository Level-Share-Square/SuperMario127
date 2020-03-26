extends LineEdit
	
func focus_exit():
	PlayerSettings.connect_to_ip = text

func _input(event):
	if event.is_action_pressed("text_release_focus"): # this should already be a thing
		release_focus()

func _ready():
	connect("focus_exited", self, "focus_exit")
